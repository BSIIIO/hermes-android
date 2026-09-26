import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_strings.dart';
import '../../main.dart';

/// Light/dark mode switch, persisted under the `theme_mode` preference.
///
/// Public (rather than a private class inside the settings screen) so the
/// Chinese-label wrap regression can be tested against the real widget instead
/// of a copy that could silently drift. See `test/theme_picker_wrap_test.dart`.
class ThemeModeCard extends StatefulWidget {
  const ThemeModeCard({super.key});

  @override
  State<ThemeModeCard> createState() => _ThemeModeCardState();
}

class _ThemeModeCardState extends State<ThemeModeCard> {
  String _mode = 'system';

  static const _preferenceKey = 'theme_mode';

  @override
  void initState() {
    super.initState();
    _loadMode();
  }

  Future<void> _loadMode() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _mode = prefs.getString(_preferenceKey) ?? 'system');
  }

  Future<void> _setMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferenceKey, mode);
    if (!mounted) return;
    setState(() => _mode = mode);
    // The MaterialApp owns the actual theme, so poke the root to rebuild.
    final rootCtx = context.findAncestorStateOfType<HermesAppState>();
    rootCtx?.setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SegmentedButton<String>(
        segments: [
          ButtonSegment(
            value: 'system',
            label: Text(
              s.themeSystem,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            icon: const Icon(Icons.brightness_auto, size: 18),
            tooltip: s.themeSystem,
          ),
          ButtonSegment(
            value: 'dark',
            label: Text(
              s.themeDark,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            icon: const Icon(Icons.dark_mode, size: 18),
            tooltip: s.themeDark,
          ),
          ButtonSegment(
            value: 'light',
            label: Text(
              s.themeLight,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            icon: const Icon(Icons.light_mode, size: 18),
            tooltip: s.themeLight,
          ),
        ],
        selected: {_mode},
        onSelectionChanged: (selection) => _setMode(selection.first),
        // SegmentedButton sizes each segment from Material's English text
        // metrics — this app deliberately never sets supportedLocales (a zh
        // delegate would be required, and the absence of flutter_localizations
        // makes the built-in delegate drop MaterialLocalizations entirely).
        // "跟随系统" is four full-width glyphs versus six half-width letters in
        // "System", and the 18dp icon plus its 8dp gap push the measured width
        // past the segment, so without the single-line + ellipsis treatment the
        // label wrapped and made the row two lines tall. The tooltip repeats
        // the label so an ellipsized string is still readable.
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          textStyle: WidgetStatePropertyAll(
            Theme.of(context).textTheme.labelMedium,
          ),
        ),
      ),
    );
  }
}
