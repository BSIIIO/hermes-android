import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/services/app_language.dart';
import 'package:hermes_android/core/services/connection_manager.dart';
import 'package:hermes_android/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Verifies that a language switch does not tear down the app's long-lived
/// objects (the connection manager, the turn-application controller) or the
/// state of the living Home screen.
///
/// This is the regression the UX review flagged: "does switching language drop
/// scroll position, or sever a live stream?" The answer has to come from the
/// element identity Flutter actually assigns, not from reading the code.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a language switch keeps HomeScreen state and the app services '
      'alive', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final appKey = GlobalKey<HermesAppState>();

    await tester.pumpWidget(
      HermesApp(key: appKey, connManager: ConnectionManager(prefs)),
    );
    await tester.pumpAndSettle();

    final homeFinder = find.byType(HomeScreen);
    expect(homeFinder, findsOneWidget);

    // Snapshot identity of the objects that must not be recreated.
    final homeStateBefore = tester.state<HomeScreenState>(homeFinder);
    final connBefore = tester.widget<HomeScreen>(homeFinder).connManager;
    final turnControllerBefore =
        tester.widget<HomeScreen>(homeFinder).turnApplicationController;
    expect(connBefore, isNotNull);
    expect(turnControllerBefore, isNotNull);

    await appKey.currentState!.setAppLanguage(AppLanguage.chinese);
    await tester.pumpAndSettle();

    // Same State object => the screen was NOT rebuilt from scratch, so an
    // active route keeps its scroll offset and its composer text.
    expect(
      tester.state<HomeScreenState>(homeFinder),
      same(homeStateBefore),
      reason: 'HomeScreenState must survive the rebuild, otherwise a language '
          'switch would reset navigation and drop in-flight input.',
    );
    expect(
      tester.widget<HomeScreen>(homeFinder).connManager,
      same(connBefore),
    );
    expect(
      tester.widget<HomeScreen>(homeFinder).turnApplicationController,
      same(turnControllerBefore),
      reason: 'the shared turn controller holds live streams; recreating it '
          'would sever an in-flight turn.',
    );
    expect(appKey.currentState, isNotNull);

    // And the language really did change underneath.
    expect(find.text('暂无连接'), findsOneWidget);
  });
}
