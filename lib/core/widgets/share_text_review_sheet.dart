import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/android_share_intent_service.dart';
import '../theme/hermes_theme.dart';
import '../utils/new_chat_options.dart';

enum ShareFavoriteAction {
  useAsIs(Icons.edit_note_rounded),
  summarize(Icons.summarize_rounded),
  explain(Icons.lightbulb_outline_rounded),
  research(Icons.travel_explore_rounded),
  extractTasks(Icons.task_alt_rounded),
  remember(Icons.memory_rounded),
  fillFromDocument(Icons.description_outlined);

  final IconData icon;
  const ShareFavoriteAction(this.icon);

  /// User-visible label in the active language.
  String label(AppStrings s) => switch (this) {
    ShareFavoriteAction.useAsIs => s.useAsIs,
    ShareFavoriteAction.summarize => s.summarize,
    ShareFavoriteAction.explain => s.explain,
    ShareFavoriteAction.research => s.research,
    ShareFavoriteAction.extractTasks => s.extractTasks,
    ShareFavoriteAction.remember => s.remember,
    ShareFavoriteAction.fillFromDocument => s.fillFromDocument,
  };
}

String buildSharedPrompt(
  ShareFavoriteAction action,
  String source, {
  bool hasAttachments = false,
}) {
  final text = source.trim();
  if (text.isEmpty && hasAttachments) {
    return switch (action) {
      ShareFavoriteAction.useAsIs => 'Review the attached content.',
      ShareFavoriteAction.summarize => 'Summarize the attached content.',
      ShareFavoriteAction.explain => 'Explain the attached content clearly.',
      ShareFavoriteAction.research =>
        'Research the attached content, verify the important claims, and cite sources.',
      ShareFavoriteAction.extractTasks =>
        'Extract the decisions, deadlines, owners, and actionable action items from the attached content.',
      ShareFavoriteAction.remember =>
        'Save the durable facts from the attached content to memory, then confirm what was retained.',
      ShareFavoriteAction.fillFromDocument =>
        'Use the attached content to identify and fill the relevant document or form fields. Ask before submitting anything.',
    };
  }
  return switch (action) {
    ShareFavoriteAction.useAsIs => text,
    ShareFavoriteAction.summarize => 'Summarize this content:\n\n$text',
    ShareFavoriteAction.explain => 'Explain this content clearly:\n\n$text',
    ShareFavoriteAction.research =>
      'Research this content, verify the important claims, and cite sources:\n\n$text',
    ShareFavoriteAction.extractTasks =>
      'Extract the decisions, deadlines, owners, and actionable action items from this content:\n\n$text',
    ShareFavoriteAction.remember =>
      'Save the durable facts from this content to memory, then confirm what was retained:\n\n$text',
    ShareFavoriteAction.fillFromDocument =>
      'Use this content to identify and fill the relevant document or form fields. Ask before submitting anything:\n\n$text',
  };
}

class ShareTextDecision {
  final ShareFavoriteAction action;
  final NewChatMode mode;

  const ShareTextDecision({required this.action, required this.mode});
}

class ShareTextReviewSheet extends StatefulWidget {
  final String sharedText;
  final List<AndroidSharedFile> sharedFiles;
  final bool projectChatEnabled;

  const ShareTextReviewSheet({
    required this.sharedText,
    this.sharedFiles = const [],
    required this.projectChatEnabled,
    super.key,
  });

  @override
  State<ShareTextReviewSheet> createState() => _ShareTextReviewSheetState();
}

class _ShareTextReviewSheetState extends State<ShareTextReviewSheet> {
  ShareFavoriteAction _action = ShareFavoriteAction.useAsIs;
  NewChatMode _mode = NewChatMode.quickChat;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          HermesSpacing.lg,
          HermesSpacing.lg,
          HermesSpacing.lg,
          HermesSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.shareToHermes,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: HermesSpacing.sm),
                    Text(
                      widget.sharedText.trim().isEmpty
                          ? s.noTextShared
                          : widget.sharedText,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (widget.sharedFiles.isNotEmpty) ...[
                      const SizedBox(height: HermesSpacing.md),
                      Text(
                        widget.sharedFiles.length == 1
                            ? s.oneAttachment
                            : s.attachmentsCount.replaceAll(
                                '{0}',
                                '${widget.sharedFiles.length}',
                              ),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: HermesSpacing.xs),
                      for (final file in widget.sharedFiles)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          leading: Icon(
                            file.isImage
                                ? Icons.image_outlined
                                : Icons.insert_drive_file_outlined,
                          ),
                          title: Text(
                            file.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(file.mediaType),
                        ),
                    ],
                    const SizedBox(height: HermesSpacing.lg),
                    Text(
                      'Action',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: HermesSpacing.sm),
                    Wrap(
                      spacing: HermesSpacing.sm,
                      runSpacing: HermesSpacing.sm,
                      children: [
                        for (final action in ShareFavoriteAction.values)
                          ChoiceChip(
                            avatar: Icon(action.icon, size: 18),
                            label: Text(action.label(s)),
                            selected: _action == action,
                            onSelected: (_) => setState(() => _action = action),
                          ),
                      ],
                    ),
                    const SizedBox(height: HermesSpacing.lg),
                    Text(
                      'Destination',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    RadioGroup<NewChatMode>(
                      groupValue: _mode,
                      onChanged: (mode) {
                        if (mode != null) setState(() => _mode = mode);
                      },
                      child: Column(
                        children: [
                          RadioListTile<NewChatMode>(
                            contentPadding: EdgeInsets.zero,
                            title: Text(s.quickChat),
                            subtitle: Text(s.quickChatAutoArchive),
                            value: NewChatMode.quickChat,
                          ),
                          RadioListTile<NewChatMode>(
                            contentPadding: EdgeInsets.zero,
                            title: Text(s.projectChat),
                            subtitle: Text(
                              widget.projectChatEnabled
                                  ? s.projectChatChooseNext
                                  : s.noActiveProjectsOnGateway,
                            ),
                            value: NewChatMode.projectChat,
                            enabled: widget.projectChatEnabled,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: HermesSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(s.commonCancel),
                ),
                const SizedBox(width: HermesSpacing.sm),
                FilledButton.icon(
                  onPressed: () => Navigator.of(
                    context,
                  ).pop(ShareTextDecision(action: _action, mode: _mode)),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(s.commonContinue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
