import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/l10n/app_strings.dart';
import 'package:hermes_android/core/services/app_language.dart';
import 'package:hermes_android/core/services/connection_manager.dart';
import 'package:hermes_android/core/services/text_size_preference.dart';
import 'package:hermes_android/core/widgets/app_language_card.dart';
import 'package:hermes_android/core/widgets/hermes_shell.dart';
import 'package:hermes_android/core/widgets/text_size_settings_card.dart';
import 'package:hermes_android/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('AppLanguage', () {
    test('system follows the Android locale; explicit choices pin one', () {
      expect(AppLanguage.system.followsSystem, isTrue);
      expect(AppLanguage.system.locale, isNull);
      expect(AppLanguage.english.locale, const Locale('en'));
      expect(AppLanguage.chinese.locale, const Locale('zh'));
    });

    test('storage round-trips every choice', () {
      for (final language in AppLanguage.values) {
        expect(
          AppLanguage.fromStorage(language.storageValue),
          language,
          reason: '${language.storageValue} must survive a save/read cycle',
        );
      }
    });

    test('unknown and missing values fall back to system, never crash', () {
      expect(AppLanguage.fromStorage(null), AppLanguage.system);
      expect(AppLanguage.fromStorage(''), AppLanguage.system);
      expect(AppLanguage.fromStorage('zh_TW'), AppLanguage.system);
      expect(AppLanguage.fromStorage('de'), AppLanguage.system);
    });

    test('persists in the same namespace as the other display preferences', () {
      expect(AppLanguage.preferenceKey, 'app_language_preference');
    });

    test('store writes and reads the raw storage value', () async {
      final prefs = await SharedPreferences.getInstance();
      final store = AppLanguageStore(prefs);

      expect(store.read(), AppLanguage.system);

      await store.save(AppLanguage.chinese);

      expect(store.read(), AppLanguage.chinese);
      expect(prefs.getString(AppLanguage.preferenceKey), 'zh');
    });
  });

  group('AppStrings', () {
    test('English values are exactly the strings that used to be hardcoded', () {
      const en = AppStringsEn();

      // Navigation.
      expect(en.navHome, 'Home');
      expect(en.navChats, 'Chats');
      expect(en.navProjects, 'Projects');
      expect(en.navBots, 'Bots');
      expect(en.navActivity, 'Activity');
      expect(en.navMore, 'More');

      // Common actions.
      expect(en.commonCancel, 'Cancel');
      expect(en.commonSave, 'Save');
      expect(en.commonSaveChanges, 'Save Changes');
      expect(en.commonDelete, 'Delete');
      expect(en.commonEditConnection, 'Edit Connection');
      expect(en.commonConnect, 'Connect');
      expect(en.commonAddConnection, 'Add Connection');
      expect(en.commonRestoreConfiguration, 'Restore configuration');
      expect(en.commonRetry, 'Retry');

      // Home empty state — the embedded newline is load-bearing: tests match
      // the whole string, so it must stay an escape and not become a real
      // line break.
      expect(en.homeNoConnections, 'No connections');
      expect(
        en.homeNoConnectionsHint,
        'Tap + to add a remote Hermes Gateway\n(API Server, port 8642)',
      );

      // Connection form.
      expect(en.connectionLabel, 'Label');
      expect(en.connectionHost, 'Host');
      expect(en.connectionPort, 'Port');
      expect(en.connectionApiKey, 'API Key');

      // Settings.
      expect(en.appearance, 'Appearance');
      expect(en.settings, 'Settings');
      expect(en.settingsTextSize, 'Text size');
      expect(en.settingsPreview, 'Preview');
      expect(en.themeSystem, 'System');
      expect(en.themeDark, 'Dark');
      expect(en.themeLight, 'Light');
      expect(en.appTitle, 'Hermes Agent');
    });

    test('Chinese translations differ and contain no leftover English prose', () {
      const zh = AppStringsZh();

      expect(zh.navHome, '首页');
      expect(zh.navChats, '会话');
      expect(zh.navProjects, '项目');
      expect(zh.navBots, '机器人');
      expect(zh.navActivity, '动态');
      expect(zh.navMore, '更多');
      expect(zh.settings, '设置');
      expect(zh.appearance, '外观');
      expect(zh.settingsTextSize, '文字大小');
      expect(zh.themeSystem, '跟随系统');
      expect(zh.commonRetry, '重试');
      expect(zh.connectionApiKey, 'API 密钥');

      // Language endonyms are intentionally identical in both languages.
      expect(zh.languageEnglish, 'English');
      expect(zh.languageChinese, '简体中文');
    });

    test('every key resolves non-empty on both implementations', () {
      // A deliberately exhaustive probe: if a getter is added to AppStrings
      // but forgotten on one implementation, this table stops compiling.
      const en = AppStringsEn();
      const zh = AppStringsZh();
      final pairs = <(String, String)>[
        (en.appTitle, zh.appTitle),
        (en.settings, zh.settings),
        (en.appearance, zh.appearance),
        (en.navHome, zh.navHome),
        (en.navChats, zh.navChats),
        (en.navProjects, zh.navProjects),
        (en.navBots, zh.navBots),
        (en.navActivity, zh.navActivity),
        (en.navMore, zh.navMore),
        (en.commonCancel, zh.commonCancel),
        (en.commonSave, zh.commonSave),
        (en.commonSaveChanges, zh.commonSaveChanges),
        (en.commonDelete, zh.commonDelete),
        (en.commonEditConnection, zh.commonEditConnection),
        (en.commonConnect, zh.commonConnect),
        (en.commonAddConnection, zh.commonAddConnection),
        (en.commonRestoreConfiguration, zh.commonRestoreConfiguration),
        (en.commonRetry, zh.commonRetry),
        (en.homeNoConnections, zh.homeNoConnections),
        (en.homeNoConnectionsHint, zh.homeNoConnectionsHint),
        (en.connectionLabel, zh.connectionLabel),
        (en.connectionHost, zh.connectionHost),
        (en.connectionPort, zh.connectionPort),
        (en.connectionApiKey, zh.connectionApiKey),
        (en.settingsTextSize, zh.settingsTextSize),
        (en.settingsPreview, zh.settingsPreview),
        (en.settingsTextSizeDescription, zh.settingsTextSizeDescription),
        (
          en.settingsTextSizeSystemDescription,
          zh.settingsTextSizeSystemDescription,
        ),
        (en.settingsTextSizePreviewBody, zh.settingsTextSizePreviewBody),
        (en.themeSystem, zh.themeSystem),
        (en.themeDark, zh.themeDark),
        (en.themeLight, zh.themeLight),
        (en.language, zh.language),
        (en.languageSheetDescription, zh.languageSheetDescription),
        (en.languageSubtitleSystem, zh.languageSubtitleSystem),
        (en.languageSubtitleExplicit, zh.languageSubtitleExplicit),
        (en.languageEnglish, zh.languageEnglish),
        (en.languageChinese, zh.languageChinese),
      ];

      for (final (english, chinese) in pairs) {
        expect(english.trim(), isNotEmpty);
        expect(chinese.trim(), isNotEmpty);
      }
    });
  });

  group('AppStringsScope', () {
    testWidgets('AppStrings.of reads the installed scope', (tester) async {
      final probed = <AppStrings>[];

      await tester.pumpWidget(
        AppStringsScope(
          strings: const AppStringsZh(),
          child: Builder(
            builder: (context) {
              probed.add(AppStrings.of(context));
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(probed, hasLength(1));
      expect(probed.single, isA<AppStringsZh>());
      expect(probed.single.navHome, '首页');
    });

    testWidgets('without a scope, AppStrings.of falls back to English', (
      tester,
    ) async {
      AppStrings? probed;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              probed = AppStrings.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(probed, isA<AppStringsEn>());
      expect(probed?.navHome, 'Home');
    });
  });

  group('HermesApp language wiring', () {
    testWidgets('an English host renders the English interface', (tester) async {
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        HermesApp(key: GlobalKey(), connManager: ConnectionManager(prefs)),
      );
      await tester.pumpAndSettle();

      expect(find.text('No connections'), findsOneWidget);
      expect(find.byTooltip('Add Connection'), findsOneWidget);
      expect(find.text('暂无连接'), findsNothing);
    });

    testWidgets('a stored Chinese choice renders the Chinese interface', (
      tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppLanguage.preferenceKey, 'zh');

      await tester.pumpWidget(
        HermesApp(key: GlobalKey(), connManager: ConnectionManager(prefs)),
      );
      await tester.pumpAndSettle();

      expect(find.text('暂无连接'), findsOneWidget);
      expect(find.byTooltip('添加连接'), findsOneWidget);
      expect(find.text('No connections'), findsNothing);
    });

    testWidgets('an unknown stored value falls back to English', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppLanguage.preferenceKey, 'klingon');

      await tester.pumpWidget(
        HermesApp(key: GlobalKey(), connManager: ConnectionManager(prefs)),
      );
      await tester.pumpAndSettle();

      expect(find.text('No connections'), findsOneWidget);
      expect(find.text('暂无连接'), findsNothing);
    });

    testWidgets('switching language rebuilds the whole app immediately', (
      tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();
      final appKey = GlobalKey<HermesAppState>();

      await tester.pumpWidget(
        HermesApp(key: appKey, connManager: ConnectionManager(prefs)),
      );
      await tester.pumpAndSettle();
      expect(find.text('No connections'), findsOneWidget);

      await appKey.currentState!.setAppLanguage(AppLanguage.chinese);
      await tester.pumpAndSettle();

      expect(find.text('暂无连接'), findsOneWidget);
      expect(find.text('No connections'), findsNothing);
      expect(prefs.getString(AppLanguage.preferenceKey), 'zh');
    });

    testWidgets('English keeps the existing text-size scaler behaviour', (
      tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();
      final appKey = GlobalKey<HermesAppState>();

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
          child: HermesApp(key: appKey, connManager: ConnectionManager(prefs)),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        MediaQuery.textScalerOf(
          tester.element(find.text('No connections')),
        ).scale(10),
        16,
      );

      await appKey.currentState!.setTextSizePreference(
        TextSizePreference.extraLarge,
      );
      await tester.pump();

      expect(
        MediaQuery.textScalerOf(
          tester.element(find.text('No connections')),
        ).scale(10),
        20.8,
      );
    });
  });

  group('HermesDestination', () {
    test('label stays English; localizedLabel carries both languages', () {
      const en = AppStringsEn();
      const zh = AppStringsZh();

      expect(HermesDestination.home.label, 'Home');
      expect(HermesDestination.chats.label, 'Chats');
      expect(HermesDestination.projects.label, 'Projects');
      expect(HermesDestination.bots.label, 'Bots');
      expect(HermesDestination.more.label, 'More');

      final englishLabels = HermesDestination.values
          .map((d) => d.localizedLabel(en))
          .toList();
      final chineseLabels = HermesDestination.values
          .map((d) => d.localizedLabel(zh))
          .toList();

      expect(englishLabels, ['Home', 'Chats', 'Projects', 'Bots', 'More']);
      expect(chineseLabels, ['首页', '会话', '项目', '机器人', '更多']);
      expect(englishLabels, isNot(equals(chineseLabels)));
    });

    test('localized labels stay unique within each language', () {
      for (final strings in const [AppStringsEn(), AppStringsZh()]) {
        final labels = HermesDestination.values
            .map((d) => d.localizedLabel(strings))
            .toSet();
        expect(labels, hasLength(HermesDestination.values.length));
      }
    });
  });

  group('AppLanguageCard', () {
    testWidgets('renders the current choice and reports a new one', (
      tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();
      AppLanguage? changed;
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        AppStringsScope(
          strings: const AppStringsEn(),
          child: MaterialApp(
            home: Scaffold(
              body: AppLanguageCard(
                preferences: prefs,
                onChanged: (language) => changed = language,
              ),
            ),
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Language: System',
        ),
        findsOneWidget,
      );
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('System — Follow the system language'), findsOneWidget);

      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('简体中文'));
      await tester.pumpAndSettle();

      expect(changed, AppLanguage.chinese);
      expect(prefs.getString(AppLanguage.preferenceKey), 'zh');
      semantics.dispose();
    });

    testWidgets('re-selecting the current choice only closes the sheet', (
      tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppLanguage.preferenceKey, 'zh');
      var changedCount = 0;

      await tester.pumpWidget(
        AppStringsScope(
          strings: const AppStringsZh(),
          child: MaterialApp(
            home: Scaffold(
              body: AppLanguageCard(
                preferences: prefs,
                onChanged: (_) => changedCount++,
              ),
            ),
          ),
        ),
      );

      expect(find.text('简体中文 — 界面语言'), findsOneWidget);

      await tester.tap(find.text('语言'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('简体中文'));
      await tester.pumpAndSettle();

      expect(changedCount, 0);
      expect(prefs.getString(AppLanguage.preferenceKey), 'zh');
    });

    testWidgets('card stays overflow-free at 320dp from 100 to 200 percent', (
      tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 640);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      for (final scale in [1.0, 1.3, 1.6, 2.0]) {
        await tester.pumpWidget(
          AppStringsScope(
            strings: const AppStringsEn(),
            child: MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: Scaffold(
                body: SingleChildScrollView(
                  child: AppLanguageCard(
                    preferences: prefs,
                    onChanged: (_) {},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Chinese card text survives 200 percent without truncation '
        'errors', (tester) async {
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        AppStringsScope(
          strings: const AppStringsZh(),
          child: MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(2.0)),
              child: child!,
            ),
            home: Scaffold(
              body: SingleChildScrollView(
                child: AppLanguageCard(
                  preferences: prefs,
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // With nothing stored the card reports "System" in the current
      // interface language, then its explanation. The point of this test is
      // that the Chinese strings render without any layout exception at 200%.
      expect(find.text('语言'), findsOneWidget);
      expect(find.text('跟随系统 — 跟随系统语言'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('TextSizeSettingsCard localization', () {
    testWidgets('the sibling card renders in the current language too', (
      tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        AppStringsScope(
          strings: const AppStringsZh(),
          child: MaterialApp(
            home: Scaffold(
              body: TextSizeSettingsCard(
                preferences: prefs,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('文字大小'), findsOneWidget);
      expect(find.text('预览'), findsOneWidget);
      expect(find.text('Text size'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('English text-size card keeps its exact previous wording', (
      tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        AppStringsScope(
          strings: const AppStringsEn(),
          child: MaterialApp(
            home: Scaffold(
              body: TextSizeSettingsCard(
                preferences: prefs,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Text size'), findsOneWidget);
      expect(
        find.text('Preview'),
        findsOneWidget,
      );
      expect(
        find.text('Hermes keeps Android accessibility text scaling active.'),
        findsOneWidget,
      );
    });
  });
}
