import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/bots_gateway_client.dart';
import '../theme/hermes_theme.dart';
import '../widgets/bot_avatar_face.dart';
import '../widgets/hermes_components.dart';

/// The Bot Mode roster of one connection.
///
/// A bot is a Hermes profile, so this screen answers one question — *which
/// bots exist here* — and reports a tap so the host decides how to open the
/// chat. It deliberately owns no transport and no navigation: [load] is
/// injected, which keeps the screen a pure function of its data.
///
/// The MVP surface is a flat roster. Groups, rooms and direct bot-to-bot
/// messaging are the same roster plus routing state, and are out of scope.
class BotsScreen extends StatefulWidget {
  /// Bots already known, so the first frame paints without a round trip.
  final List<HermesBot> bots;

  /// Refreshes the roster. Throw to surface an error state.
  final Future<List<HermesBot>> Function() load;

  /// Reports a tapped bot.
  final ValueChanged<HermesBot> onOpenBot;

  const BotsScreen({
    required this.bots,
    required this.load,
    required this.onOpenBot,
    super.key,
  });

  @override
  State<BotsScreen> createState() => BotsScreenState();
}

/// The roster's state, public so a host that keeps this screen mounted — a
/// navigation destination rather than a pushed route — can ask it to re-read
/// after a bot's chat has been written to.
class BotsScreenState extends State<BotsScreen> {
  late List<HermesBot> _bots = widget.bots;
  bool _loading = true;
  Object? _error;

  bool get _isUnsupported => _error is BotsUnsupportedException;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  /// Re-reads the roster.
  ///
  /// Public because a destination pane is never disposed: the turn count and
  /// preview on a row would otherwise stay at whatever they were when the
  /// pane was first built, even after the bot just spoke.
  Future<void> refresh() => _refresh();

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final bots = await widget.load();
      if (!mounted) return;
      setState(() {
        _bots = bots;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final tokens = HermesTokens.of(context);

    return Scaffold(
      // A pushed route paints no background of its own: without this Scaffold
      // the page inherits the nearest Material's `canvasColor`, and this theme
      // never overrides `canvasColor` — so it stays the M3 seed default, which
      // is near-black under either brightness. Every sibling screen declares
      // its own Scaffold for exactly this reason.
      backgroundColor: tokens.surface,
      appBar: AppBar(title: Text(s.botsTitle)),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                HermesSpacing.lg,
                HermesSpacing.lg,
                HermesSpacing.lg,
                HermesSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.botsTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: HermesSpacing.xs),
                  Text(
                    s.botsSubtitle,
                    style: tokens.typography.body.copyWith(color: tokens.muted),
                  ),
                ],
              ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(HermesSpacing.lg),
                child: LoadingSkeleton(rows: 5),
              )
            else if (_isUnsupported)
              // An older gateway is not a failure the user caused, so it gets
              // the informational treatment rather than a retry button.
              Padding(
                padding: const EdgeInsets.all(HermesSpacing.xl),
                child: ErrorState.unsupported(
                  title: s.botsErrorTitle,
                  message: s.botsUnsupportedHint,
                ),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.all(HermesSpacing.lg),
                child: ErrorState(
                  title: s.botsErrorTitle,
                  message: _error.toString(),
                  onRetry: _refresh,
                ),
              )
            else if (_bots.isEmpty)
              EmptyState(
                icon: Icons.smart_toy_outlined,
                title: s.botsEmptyTitle,
                message: s.botsEmptyHint,
              )
            else
              for (final bot in _bots)
                _BotRow(bot: bot, onTap: () => widget.onOpenBot(bot)),
            const SizedBox(height: HermesSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _BotRow extends StatelessWidget {
  final HermesBot bot;
  final VoidCallback onTap;

  const _BotRow({required this.bot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final tokens = HermesTokens.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: HermesSpacing.lg,
        vertical: HermesSpacing.xs,
      ),
      child: Semantics(
        button: true,
        label: s.botsChatWithTitle.replaceAll('{0}', bot.displayTitle),
        child: HermesCard(
          onTap: onTap,
          child: Row(
            children: [
              _BotAvatar(bot: bot),
              const SizedBox(width: HermesSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bot.displayTitle,
                      style: tokens.typography.section,
                    ),
                    if (bot.description.isNotEmpty) ...[
                      const SizedBox(height: HermesSpacing.xs),
                      Text(
                        bot.description,
                        style: tokens.typography.body.copyWith(
                          color: tokens.muted,
                        ),
                      ),
                    ],
                    // Model and turn count are separate widgets rather than
                    // one joined line, so each fact stays independently
                    // assertable and a missing one never shifts the other.
                    if (bot.model != null) ...[
                      const SizedBox(height: HermesSpacing.xs),
                      Text(
                        s.botsModelLine.replaceAll('{0}', bot.model!),
                        style: tokens.typography.label.copyWith(
                          color: tokens.muted,
                        ),
                      ),
                    ],
                    if (bot.botChatMessageCount > 0) ...[
                      const SizedBox(height: HermesSpacing.xs),
                      Text(
                        s.botsTurnCount.replaceAll(
                          '{0}',
                          '${bot.botChatMessageCount}',
                        ),
                        style: tokens.typography.label.copyWith(
                          color: tokens.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: HermesSpacing.sm),
              Icon(Icons.chevron_right, color: tokens.muted),
            ],
          ),
        ),
      ),
    );
  }
}

/// The bot's avatar: the desktop's drawn face, or a stored portrait.
///
/// The rows no longer show a colour wash with an initial in it — the initial
/// carried no identity that the name next to it does not already carry, and
/// suppressing it is what makes room for the face. Resolution is exactly the
/// desktop's `BotRow`: a real portrait wins, a 160x160 backfill raster of the
/// vector face is dropped, and otherwise the face is drawn from the profile's
/// Bot Mode shape and colour (falling back to the derived hue and shape when
/// the profile does not pin either).
class _BotAvatar extends StatelessWidget {
  final HermesBot bot;

  const _BotAvatar({required this.bot});

  @override
  Widget build(BuildContext context) {
    final source = BotAvatarSource.resolve(
      profileName: bot.name,
      shape: bot.shape,
      colorHex: bot.colorHex,
      imageKind: bot.imageKind,
      hasAvatar: bot.hasAvatar,
    );

    if (source.kind == BotAvatarKind.photo && source.image != null) {
      return ExcludeSemantics(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(HermesRadius.sm),
          child: Image.memory(
            source.image!,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
          ),
        ),
      );
    }

    return ExcludeSemantics(
      child: BotFace(
        source: source,
        // Idle for now: the roster has no live run state per bot, so nothing
        // selects the working pose. Wiring that is a follow-up with the same
        // data that drives the blocked count.
        mood: BotFaceMood.idle,
        size: 40,
      ),
    );
  }
}
