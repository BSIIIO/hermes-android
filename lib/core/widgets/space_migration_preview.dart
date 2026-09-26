/// The read-only Spaces → Projects migration preview.
///
/// The roadmap requires the local Spaces prototype to be migrated onto
/// server-owned Projects *only* after the user has seen exactly what would
/// happen. This widget renders [SpaceMigrationPlan] — which never writes
/// anything — so the preview is honest by construction: it shows matches,
/// the projects that would have to be created, and how many chats are
/// involved, while stating plainly that nothing has moved.
///
/// See `docs/ANDROID_DAILY_DRIVER_ROADMAP.md` ("Migration of the current
/// Spaces prototype").
library;

import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/projects_repository.dart';
import '../theme/hermes_theme.dart';
import 'hermes_components.dart';

class SpaceMigrationPreview extends StatefulWidget {
  final SpaceMigrationPlan plan;
  final VoidCallback? onDismiss;
  final Future<SpaceMigrationResult> Function()? onMigrate;

  const SpaceMigrationPreview({
    required this.plan,
    this.onDismiss,
    this.onMigrate,
    super.key,
  });

  @override
  State<SpaceMigrationPreview> createState() => _SpaceMigrationPreviewState();
}

class _SpaceMigrationPreviewState extends State<SpaceMigrationPreview> {
  bool _migrating = false;
  SpaceMigrationResult? _result;
  Object? _error;

  static String _chats(AppStrings s, int count) => count == 1
      ? s.migrationOneChat
      : s.migrationChatCount.replaceAll('{0}', '$count');

  String get _summary {
    final s = AppStrings.of(context);
    final plan = widget.plan;
    final spaces = plan.entries.length == 1
        ? s.migrationOneSpace
        : s.migrationSpaceCount.replaceAll('{0}', '${plan.entries.length}');
    final toCreate = plan.projectsToCreate;
    final projects = switch (toCreate) {
      0 => s.migrationNoProjectsNeeded,
      1 => s.migrationOneProjectToCreate,
      _ => s.migrationProjectsToCreate.replaceAll('{0}', '$toCreate'),
    };
    return '$spaces · ${_chats(s, plan.sessionsToLink)} · $projects';
  }

  Future<void> _runMigration() async {
    final migrate = widget.onMigrate;
    if (migrate == null || _migrating) return;
    setState(() {
      _migrating = true;
      _error = null;
    });
    try {
      final result = await migrate();
      if (!mounted) return;
      setState(() => _result = result);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _migrating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final tokens = HermesTokens.of(context);
    final plan = widget.plan;

    if (plan.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          EmptyState(
            icon: Icons.swap_horiz_rounded,
            title: s.migrationNothingToMigrate,
            message: s.migrationNoLocalSpaces,
          ),
          if (widget.onDismiss != null)
            TextButton(onPressed: widget.onDismiss, child: Text(s.close)),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: HermesSpacing.xl),
      children: [
        SectionHeader(title: s.migrationPreview),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: HermesSpacing.lg),
          child: Text(
            _summary,
            style: tokens.typography.body.copyWith(color: tokens.onSurface),
          ),
        ),
        const SizedBox(height: HermesSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: HermesSpacing.lg),
          child: Text(
            s.migrationPreviewOnly,
            style: tokens.typography.label.copyWith(color: tokens.muted),
          ),
        ),
        if (_result case final result?) ...[
          const SizedBox(height: HermesSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: HermesSpacing.lg),
            child: HermesCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.isComplete
                        ? s.migrationComplete
                        : s.migrationIncomplete,
                    style: tokens.typography.section.copyWith(
                      color: tokens.onSurface,
                    ),
                  ),
                  const SizedBox(height: HermesSpacing.xs),
                  Text(
                    s.migrationResultSummary
                        .replaceAll('{0}', '${result.linkedSessions}')
                        .replaceAll('{1}', '${result.createdProjects}'),
                    style: tokens.typography.body.copyWith(color: tokens.muted),
                  ),
                  if (result.unlinkedSessions > 0)
                    Text(
                      s.migrationUnlinkedWarning.replaceAll(
                        '{0}',
                        '${result.unlinkedSessions}',
                      ),
                      style: tokens.typography.body.copyWith(
                        color: tokens.muted,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: HermesSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: HermesSpacing.lg),
            child: Text(
              s.migrationFailedUnchanged,
              style: tokens.typography.body.copyWith(color: tokens.danger),
            ),
          ),
        ],
        const SizedBox(height: HermesSpacing.md),
        for (final entry in plan.entries)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              HermesSpacing.lg,
              0,
              HermesSpacing.lg,
              HermesSpacing.md,
            ),
            child: _EntryCard(entry: entry),
          ),
        if (widget.onMigrate != null && _result?.isComplete != true)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: HermesSpacing.lg),
            child: FilledButton.icon(
              onPressed: _migrating ? null : _runMigration,
              icon: _migrating
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.swap_horiz_rounded),
              label: Text(_migrating ? s.migrating : s.migrate),
            ),
          ),
        if (widget.onDismiss != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: HermesSpacing.lg),
            child: TextButton(
              onPressed: _migrating ? null : widget.onDismiss,
              child: Text(s.close),
            ),
          ),
      ],
    );
  }
}

class _EntryCard extends StatelessWidget {
  final SpaceMigrationEntry entry;

  const _EntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final tokens = HermesTokens.of(context);
    final matched = entry.matchedProject;
    final assigned = entry.sessionCount == 1
        ? s.migrationOneAssignedChat
        : s.migrationAssignedChatCount.replaceAll(
            '{0}',
            '${entry.sessionCount}',
          );

    return HermesCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  entry.space.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: tokens.typography.section.copyWith(
                    color: tokens.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: HermesSpacing.sm),
              StatusChip(
                status: matched == null
                    ? HermesStatus.blocked
                    : HermesStatus.completed,
                label: matched == null ? s.migrationNewProject : s.matched,
              ),
            ],
          ),
          const SizedBox(height: HermesSpacing.xs),
          Text(
            matched == null
                ? s.migrationNoServerProject.replaceAll('{0}', assigned)
                : s.migrationMatchesProject
                      .replaceAll('{0}', matched.name)
                      .replaceAll('{1}', assigned),
            style: tokens.typography.body.copyWith(color: tokens.muted),
          ),
        ],
      ),
    );
  }
}
