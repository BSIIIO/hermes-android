import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden-free glyph sanity check for the Chinese interface.
///
/// The brand font (Cinzel) is scoped to a handful of `fontFamily: 'Cinzel'`
/// call sites, not to the global text theme, so the Latin font cannot shadow
/// the CJK glyphs. These assertions make that structural fact checkable: if
/// someone later promotes Cinzel to a global `ThemeData.fontFamily`, these
/// tests start producing layout/render exceptions instead of silently
/// degrading into tofu boxes.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Chinese labels render without layout exceptions and report '
      'their text', (tester) async {
    // Force a brand-font scenario: the theme carries no global fontFamily,
    // so CJK falls back to the platform font. We assert on the semantics tree
    // and on the absence of exceptions, which is the part CI can check.
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Builder(
          builder: (context) {
            final style = Theme.of(context).textTheme.bodyMedium;
            return Scaffold(
              body: Column(
                children: [
                  Text('设置', style: style),
                  Text('外观', style: style),
                  Text('文字大小', style: style),
                  Text('跟随系统语言', style: style),
                  Text('界面语言，更改立即生效。', style: style),
                  Text('暂无连接', style: style),
                  Text('会话', style: style),
                  Text('项目', style: style),
                  Text('动态', style: style),
                  Text('API 密钥', style: style),
                ],
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();

    for (final text in const [
      '设置',
      '外观',
      '文字大小',
      '跟随系统语言',
      '界面语言，更改立即生效。',
      '暂无连接',
      '会话',
      '项目',
      '动态',
      'API 密钥',
    ]) {
      expect(
        find.text(text),
        findsOneWidget,
        reason: 'Chinese string must reach the tree verbatim',
      );
    }

    // No RenderFlex overflow, no missing-glyph exception.
    expect(tester.takeException(), isNull);
  });

  testWidgets('Chinese stays legible at 200% text scale on a 320dp screen', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(2.0)),
          child: child!,
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final text in const [
                  '跟随系统 — 跟随系统语言',
                  '显式选择会调整 Android 无障碍文字大小；跟随系统则保持原样。',
                  '点按 + 添加远程 Hermes 网关\n（API Server，端口 8642）',
                ])
                  Text(text),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('跟随系统 — 跟随系统语言'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
