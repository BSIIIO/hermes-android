import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/l10n/app_strings.dart';
import 'package:hermes_android/core/screens/bots_screen.dart';
import 'package:hermes_android/core/services/bots_gateway_client.dart';
import 'package:hermes_android/core/theme/hermes_theme.dart';

final _bots = [
  HermesBot.fromJson({
    'name': 'default',
    'description': '',
    'model': 'cn:hy4-preview',
    'skill_count': 417,
    'has_avatar': false,
    'canonical_session': {
      'id': '20260923_000418_4e7570',
      'preview': 'READY',
      'message_count': 71,
    },
    'ui_meta': {
      'hermes-bots': {
        'title': '',
        'shape': 'squircle',
        'color': '#8b5cf6',
        'imageKind': 'shape',
        'custom': true,
      },
    },
  }),
  HermesBot.fromJson({
    'name': 'cto',
    'description': '技术最高负责人',
    'model': 'step-5-preview',
    'skill_count': 429,
    'has_avatar': false,
    'canonical_session': {
      'id': '20260923_000929_e137a1',
      'preview': '上一轮摘要',
      'message_count': 256,
    },
    'ui_meta': {
      'hermes-bots': {'title': '首席技术官（CTO）', 'color': '#ef4444'},
    },
  }),
];

Future<void> _pump(
  WidgetTester tester, {
  required List<HermesBot> bots,
  required Future<List<HermesBot>> Function() load,
  required void Function(HermesBot bot) onOpenBot,
  Size size = const Size(360, 1600),
  double textScale = 1.0,
  Brightness brightness = Brightness.dark,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: MaterialApp(
        theme: hermesTheme(brightness),
        home: Scaffold(
          body: BotsScreen(bots: bots, load: load, onOpenBot: onOpenBot),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('BotsScreen', () {
    testWidgets('renders the roster with Bot Mode titles', (tester) async {
      await _pump(
        tester,
        bots: _bots,
        load: () async => _bots,
        onOpenBot: (_) {},
      );

      // The default profile carries an empty Bot Mode title, so the row must
      // fall back to its profile name instead of rendering blank.
      expect(find.text('default'), findsOneWidget);
      expect(find.text('首席技术官（CTO）'), findsOneWidget);
      expect(find.text('技术最高负责人'), findsOneWidget);
    });

    testWidgets('shows the turn count of an existing Bot Chat', (tester) async {
      final s = AppStringsEn();
      await _pump(
        tester,
        bots: _bots,
        load: () async => _bots,
        onOpenBot: (_) {},
      );

      expect(
        find.text(s.botsTurnCount.replaceAll('{0}', '256')),
        findsOneWidget,
      );
      expect(
        find.text(s.botsModelLine.replaceAll('{0}', 'step-5-preview')),
        findsOneWidget,
      );
    });

    testWidgets('opening a bot reports which bot was tapped', (tester) async {
      final opened = <String>[];
      await _pump(
        tester,
        bots: _bots,
        load: () async => _bots,
        onOpenBot: (bot) => opened.add(bot.name),
      );

      await tester.tap(find.text('首席技术官（CTO）'));
      await tester.pumpAndSettle();

      expect(opened, ['cto']);
    });

    testWidgets('shows an explanatory empty state', (tester) async {
      final s = AppStringsEn();
      await _pump(
        tester,
        bots: const [],
        load: () async => const [],
        onOpenBot: (_) {},
      );

      expect(find.text(s.botsEmptyTitle), findsOneWidget);
      expect(find.text(s.botsEmptyHint), findsOneWidget);
    });

    testWidgets('paints the themed surface, not the route canvas',
        (tester) async {
      // Regression: this screen once returned a bare RefreshIndicator, so a
      // pushed route inherited the nearest Material's `canvasColor`. The
      // theme never overrides `canvasColor`, so that default is near-black
      // under BOTH brightnesses — the report was a black menu in light mode
      // while the chat it opened was white.
      await _pump(
        tester,
        bots: _bots,
        load: () async => _bots,
        onOpenBot: (_) {},
      );

      // The BotsScreen's own Scaffold, not the harness's `home:` wrapper.
      final scope = find.ancestor(
        of: find.byType(RefreshIndicator),
        matching: find.byType(Scaffold),
      );
      final scaffold = tester.widget<Scaffold>(scope.first);
      expect(scaffold.backgroundColor, isNotNull);
      expect(
        scaffold.backgroundColor,
        HermesTokens.forBrightness(Brightness.dark).surface,
      );
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('paints the light surface when the app follows a light theme',
        (tester) async {
      // The same scaffold must follow the theme, not a hardcoded colour, or
      // the menu is black on a white app.
      await _pump(
        tester,
        bots: _bots,
        load: () async => _bots,
        onOpenBot: (_) {},
        brightness: Brightness.light,
      );

      // The BotsScreen's own Scaffold, not the harness's `home:` wrapper.
      final scope = find.ancestor(
        of: find.byType(RefreshIndicator),
        matching: find.byType(Scaffold),
      );
      final scaffold = tester.widget<Scaffold>(scope.first);
      expect(
        scaffold.backgroundColor,
        HermesTokens.forBrightness(Brightness.light).surface,
      );
    });

    testWidgets('surfaces a load failure with a retry', (tester) async {
      final s = AppStringsEn();
      var attempts = 0;
      await _pump(
        tester,
        bots: const [],
        load: () async {
          attempts++;
          throw Exception('socket closed');
        },
        onOpenBot: (_) {},
      );

      expect(find.text(s.botsErrorTitle), findsOneWidget);
      expect(find.textContaining('socket closed'), findsOneWidget);

      await tester.tap(find.text(s.commonRetry));
      await tester.pumpAndSettle();

      expect(attempts, 2);
    });

    testWidgets('an unsupported gateway reads as a notice, not an error',
        (tester) async {
      final s = AppStringsEn();
      await _pump(
        tester,
        bots: const [],
        load: () async => throw const BotsUnsupportedException(
          'profiles.list',
          'unknown method: profiles.list',
        ),
        onOpenBot: (_) {},
      );

      expect(find.text(s.botsErrorTitle), findsOneWidget);
      expect(find.text(s.botsUnsupportedHint), findsOneWidget);
      expect(find.text(s.commonRetry), findsNothing);
    });

    testWidgets('survives a large text scale', (tester) async {
      await _pump(
        tester,
        bots: _bots,
        load: () async => _bots,
        onOpenBot: (_) {},
        textScale: 1.6,
      );

      expect(tester.takeException(), isNull);
      expect(find.text('首席技术官（CTO）'), findsOneWidget);
    });
  });
}
