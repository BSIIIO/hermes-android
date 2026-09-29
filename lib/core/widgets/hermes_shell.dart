/// The Hermes Android navigation shell.
///
/// Replaces drawer-hidden navigation with the validated top-level structure
/// Home / Projects / Bots / More, so every capability is one tap away.
/// Adapts to a bottom bar on phones and a side rail on tablets/foldables.
/// See `docs/ANDROID_DAILY_DRIVER_ROADMAP.md`.
library;

import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../theme/hermes_theme.dart';

/// A top-level destination of the Hermes app.
///
/// The order is the display order in the bottom bar and the side rail, so
/// inserting a destination moves a button — it does not add a menu level.
enum HermesDestination {
  /// Attention-first dashboard: what needs you, what is running.
  home,

  /// Every conversation, with recent, unassigned, archived, and search views.
  chats,

  /// Server-owned Projects and their chats, files, assets, and activity.
  projects,

  /// The Bot Mode roster: one row per Hermes profile, opening that bot's own
  /// canonical chat. Lives in the primary bar because a bot is a peer of a
  /// chat, not a setting.
  bots,

  /// Everything else: files, assets, search, cron, skills, settings.
  more;

  String get label {
    switch (this) {
      case HermesDestination.home:
        return 'Home';
      case HermesDestination.chats:
        return 'Chats';
      case HermesDestination.projects:
        return 'Projects';
      case HermesDestination.bots:
        return 'Bots';
      case HermesDestination.more:
        return 'More';
    }
  }

  /// The label in the current interface language.
  ///
  /// [label] stays English on purpose: it is a stable identifier that tests,
  /// tooling, and docs refer to, and changing it would break contracts that
  /// have nothing to do with display language. Only the rendered bar and rail
  /// read [localizedLabel].
  String localizedLabel(AppStrings strings) {
    switch (this) {
      case HermesDestination.home:
        return strings.navHome;
      case HermesDestination.chats:
        return strings.navChats;
      case HermesDestination.projects:
        return strings.navProjects;
      case HermesDestination.bots:
        return strings.navBots;
      case HermesDestination.more:
        return strings.navMore;
    }
  }

  IconData get icon {
    switch (this) {
      case HermesDestination.home:
        return Icons.home_outlined;
      case HermesDestination.chats:
        return Icons.chat_bubble_outline;
      case HermesDestination.projects:
        return Icons.folder_outlined;
      case HermesDestination.bots:
        return Icons.smart_toy_outlined;
      case HermesDestination.more:
        return Icons.more_horiz;
    }
  }

  IconData get selectedIcon {
    switch (this) {
      case HermesDestination.home:
        return Icons.home_rounded;
      case HermesDestination.chats:
        return Icons.chat_bubble_rounded;
      case HermesDestination.projects:
        return Icons.folder_rounded;
      case HermesDestination.bots:
        return Icons.smart_toy_rounded;
      case HermesDestination.more:
        return Icons.more_horiz_rounded;
    }
  }
}

/// Builds the pane for one destination.
typedef HermesPaneBuilder =
    Widget Function(BuildContext context, HermesDestination destination);

/// The adaptive navigation shell.
///
/// [badges] drives attention counts (for example pending approvals on
/// Activity); a zero or negative count renders nothing so the bar stays calm
/// when there is nothing to report.
class HermesShell extends StatefulWidget {
  /// Below this width the shell uses a bottom bar; at or above it, a rail.
  static const double railBreakpoint = 720;

  static const int maxBadgeCount = 99;

  final HermesPaneBuilder builder;
  final HermesDestination initialDestination;
  final Map<HermesDestination, int> badges;
  final ValueChanged<HermesDestination>? onDestinationChanged;

  /// The shell's floating action button.
  ///
  /// Owned here rather than by a host Scaffold: the shell draws the bottom
  /// bar, so a FAB placed above it would float over the last destination and
  /// swallow its taps.
  final Widget? floatingActionButton;

  const HermesShell({
    required this.builder,
    this.initialDestination = HermesDestination.home,
    this.badges = const {},
    this.onDestinationChanged,
    this.floatingActionButton,
    super.key,
  });

  @override
  State<HermesShell> createState() => _HermesShellState();
}

class _HermesShellState extends State<HermesShell> {
  late HermesDestination _current = widget.initialDestination;
  late final Set<HermesDestination> _visitedDestinations = {
    widget.initialDestination,
  };

  void _select(HermesDestination destination) {
    // Re-tapping the active destination is a no-op rather than a rebuild or a
    // duplicate notification: callers use the callback for analytics/state.
    if (destination == _current) return;
    setState(() {
      _current = destination;
      _visitedDestinations.add(destination);
    });
    widget.onDestinationChanged?.call(destination);
  }

  Widget? _badge(HermesDestination destination) {
    final count = widget.badges[destination] ?? 0;
    if (count <= 0) return null;
    final text = count > HermesShell.maxBadgeCount
        ? '${HermesShell.maxBadgeCount}+'
        : '$count';
    return Badge(label: Text(text));
  }

  Widget _icon(HermesDestination destination, {required bool selected}) {
    final icon = Icon(selected ? destination.selectedIcon : destination.icon);
    final badge = _badge(destination);
    if (badge == null) return icon;
    return Badge(label: (badge as Badge).label, child: icon);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = HermesTokens.of(context);
    final strings = AppStrings.of(context);
    final useRail =
        MediaQuery.sizeOf(context).width >= HermesShell.railBreakpoint;

    // Keep every visited destination mounted so local UI state (search text,
    // selected filters, scroll position) survives switching away and back.
    // Unvisited panes stay as inert placeholders: building all destinations
    // eagerly would start their network reads before the user opens them.
    final pane = IndexedStack(
      index: _current.index,
      children: [
        for (final destination in HermesDestination.values)
          if (_visitedDestinations.contains(destination))
            KeyedSubtree(
              key: ValueKey(destination),
              child: widget.builder(context, destination),
            )
          else
            const SizedBox.shrink(),
      ],
    );

    if (useRail) {
      return Scaffold(
        backgroundColor: tokens.surface,
        floatingActionButton: widget.floatingActionButton,
        body: Row(
          children: [
            NavigationRail(
              backgroundColor: tokens.surface,
              selectedIndex: _current.index,
              onDestinationSelected: (index) =>
                  _select(HermesDestination.values[index]),
              labelType: NavigationRailLabelType.all,
              indicatorColor: tokens.accent.withValues(alpha: 0.18),
              destinations: [
                for (final destination in HermesDestination.values)
                  NavigationRailDestination(
                    icon: _icon(destination, selected: false),
                    selectedIcon: _icon(destination, selected: true),
                    label: Text(destination.localizedLabel(strings)),
                  ),
              ],
            ),
            VerticalDivider(width: 1, color: tokens.border),
            Expanded(child: pane),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: tokens.surface,
      body: pane,
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: NavigationBar(
        backgroundColor: tokens.raised,
        indicatorColor: tokens.accent.withValues(alpha: 0.18),
        selectedIndex: _current.index,
        onDestinationSelected: (index) =>
            _select(HermesDestination.values[index]),
        destinations: [
          for (final destination in HermesDestination.values)
            NavigationDestination(
              icon: _icon(destination, selected: false),
              selectedIcon: _icon(destination, selected: true),
              label: destination.localizedLabel(strings),
            ),
        ],
      ),
    );
  }
}
