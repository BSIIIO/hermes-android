import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/l10n/app_strings.dart';
import 'package:hermes_android/core/widgets/theme_mode_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Regression tests for the theme-mode picker.
///
/// The control is a [SegmentedButton] whose segments are sized from Material's
/// **English** text metrics, because this app intentionally never sets
/// `supportedLocales` — doing so without a zh delegate drops MaterialLocalizations
/// and kills every AppBar/Dialog (see docs/i18n-scope-decision.md). Chinese
/// "跟随系统" is 4 full-width glyphs where the English "System" is 6 half-width
/// letters, and the 18dp icon plus its 8dp gap push the measured width past the
/// segment, so the label used to wrap and made the row two lines tall.
///
/// These tests exercise the real widget, not a copy, so they cannot drift from
/// the code they guard.
void main() {
  // The card reads its persisted mode in initState, so the store must exist
  // before it is pumped or nothing renders at all.
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('segment labels stay on one line with an ellipsis fallback', (
    tester,
  ) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('zh', 'CN'),
        home: Scaffold(body: ThemeModeCard()),
      ),
    );

    final labels = tester.widgetList<Text>(
      find.descendant(
        of: find.byType(SegmentedButton<String>),
        matching: find.byType(Text),
      ),
    );
    expect(labels.length, 3, reason: 'system / dark / light');
    for (final label in labels) {
      expect(
        label.maxLines,
        1,
        reason: 'a wrapping segment label makes the whole row two lines tall',
      );
      expect(
        label.overflow,
        TextOverflow.ellipsis,
        reason: 'the label must shrink rather than wrap',
      );
    }
  });

  testWidgets('every segment tooltip repeats its label', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('zh', 'CN'),
        home: Scaffold(body: ThemeModeCard()),
      ),
    );

    final button = tester.widget<SegmentedButton<String>>(
      find.byType(SegmentedButton<String>),
    );
    expect(button.segments.length, 3);
    for (final segment in button.segments) {
      final label = segment.label as Text;
      expect(
        segment.tooltip,
        label.data,
        reason:
            'the tooltip must repeat the label so an ellipsized CJK '
            'string remains readable',
      );
    }
  });

  testWidgets('renders through the ambient AppStringsScope', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    const zh = AppStringsZh();

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('zh', 'CN'),
        home: Scaffold(body: ThemeModeCard()),
      ),
    );

    // AppStrings.of() falls back to English when no AppStringsScope is
    // installed (AppStringsScope is published by MaterialApp.builder in
    // main.dart, which this bare test app does not use). That fallback is
    // deliberate — an English default beats a crash — so assert it here rather
    // than asserting the zh strings, which requires the real app root.
    expect(find.text(const AppStringsEn().themeSystem), findsOneWidget);

    // With the scope present the same widget renders the zh labels.
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('zh', 'CN'),
        home: Scaffold(
          body: AppStringsScope(
            strings: zh,
            child: ThemeModeCard(),
          ),
        ),
      ),
    );
    expect(find.text(zh.themeSystem), findsOneWidget);
    expect(find.text(zh.themeDark), findsOneWidget);
    expect(find.text(zh.themeLight), findsOneWidget);
  });
}
