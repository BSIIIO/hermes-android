import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/theme/hermes_theme.dart';

/// Documents the Radio accent colour and guards the brand's gold identity.
///
/// The UI design spec asked for an explicit `RadioThemeData` pinned to
/// `HermesTokens.hermesGold` rather than leaving the Radio to
/// `colorScheme.primary`, which Material 3 derives from the gold seed and
/// shifts away from the brand hex. These assertions pin both facts:
///
///  * `hermesGold` is still `#D4AF37`;
///  * the selected Radio resolves to that hex, not to the derived primary.
///
/// If a future refactor deletes `radioTheme` from `hermesTheme`, the second
/// assertion fails and someone has to consciously decide to give up the brand
/// colour — it cannot silently regress.
void main() {
  test('hermesGold is the documented brand hex', () {
    expect(HermesTokens.hermesGold, const Color(0xFFD4AF37));
  });

  test('a selected Radio resolves to the brand gold in both brightnesses', () {
    for (final brightness in [Brightness.dark, Brightness.light]) {
      final theme = hermesTheme(brightness);

      // The theme must carry an explicit RadioThemeData; this is what keeps
      // the accent on-brand instead of tracking the derived colour scheme.
      final fill = theme.radioTheme.fillColor;
      expect(fill, isNotNull, reason: 'radioTheme must be set by hermesTheme');

      final selected = fill!.resolve(<WidgetState>{WidgetState.selected});
      expect(
        selected,
        HermesTokens.hermesGold,
        reason: 'selected Radio must be the brand hex, not a Material 3 '
            'tonal derivation of the seed',
      );

      // And the unselected state deliberately falls back to the scheme so the
      // idle dot stays legible in both themes.
      final idle = fill.resolve(<WidgetState>{});
      expect(
        idle,
        isNull,
        reason: 'idle fill is left to ColorScheme defaults on purpose',
      );
      expect(
        theme.colorScheme.primary,
        isNot(equals(HermesTokens.hermesGold)),
        reason: 'documents why the explicit RadioThemeData is needed at all',
      );
    }
  });
}
