# 界面语言切换（English / 简体中文）— 范围决策

> 状态：已定案，Stage 1 已实现（见 `feat/i18n-chinese-ui` 分支）。
> 本文件回答「为什么只做这些字符串」「为什么不换 gen-l10n」「为什么不改 pubspec」。

## 1. 技术路线：手写契约，不用 gen-l10n

| 维度 | gen-l10n（l10n.yaml + .arb + 代码生成） | 手写 `AppStrings` + `AppLanguage`（本文方案） |
|---|---|---|
| 是否需要新依赖 | **需要**。Material 本地化要 `flutter_localizations`（连带 `intl`），`pubspec.yaml` 与 `pubspec.lock` 都要改 | **不需要**。新代码只 `import package:flutter/material.dart` 和 `package:shared_preferences` |
| CI 红线 | 改 `pubspec.yaml` 有误伤版本行的风险（`pr-quality.yml` 要求 `versionCode == 2143` 精确相等）；`pubspec.lock` 变更会让 CI 首跑必须联网解析新包 | `git diff pubspec.yaml pubspec.lock` 为空 |
| 与仓库范式一致性 | 全新范式，引入 `AppLocalizations.of(context)` 的隐式 delegate 链 | 1:1 复刻 `text_size_preference.dart` 的 `enum + storageValue + Store` 和 `text_size_settings_card.dart` 的卡片结构 |
| 编译前提 | 生成的 `.g.dart` 必须在没有 SDK 的环境里手抄，任何字段名偏差都编译失败且无法本地验证 | 纯手写 Dart，`flutter analyze` 即可保证正确 |
| 现状契合度 | 复数规则 / `Intl.plural` 用不上——两种语言的 P0 全是短标签 | 恰好覆盖需求 |

**迁移触发条件（显式技术债）**：出现以下任一情况才重新评估 gen-l10n ——
需要复数规则、需要日期/数字本地化、或语言数超过 3 种。

## 2. 为什么 `MaterialApp` 不声明 `supportedLocales`

这是实现中发现的一个真实陷阱，值得单独记：Flutter 内置的 `DefaultMaterialLocalizations.delegate`
**只支持 `languageCode == 'en'`**（见 `packages/flutter/lib/src/material/material_localizations.dart`
的 `_MaterialLocalizationsDelegate.isSupported`）。支持中文 Material 文案的 delegate 在
`flutter_localizations` 包里，而本 App 不依赖它。

因此：

- ❌ 写 `supportedLocales: const [Locale('en'), Locale('zh')]` 而不加 delegate
  → Flutter 打出 locale 不受支持的警告，并**丢掉内置的 `MaterialLocalizations`**，
  之后每棵 `AppBar` / `Dialog` / `TextField` 都抛 "No MaterialLocalizations found"，
  整个应用崩。
- ✅ 只设 `locale: Locale('zh')`，不设 `supportedLocales`，自己的 `AppStrings` 走
  `AppStringsScope`（`InheritedWidget`）→ 中文文案由我们自己提供，Material 内置文案
  继续走 en 默认值（本 App 的 P0 范围内没有任何 Material 内置文案需要中文，
  `Tooltip`/`SnackBar` 等由我们自己的字符串驱动）。

这个坑被 `test/app_language_test.dart` 的 `HermesApp language wiring` 组覆盖：
切换到中文后仍要能挂载 AppBar、FloatingActionButton tooltip、AlertDialog。

## 3. 范围分层

全库 `.dart` 168 个文件、约 731 个用户可见字符串候选。**一次全量替换 = 把 76 个既有测试
文件一起拖进回归深渊**，review 不可能完成。分层如下：

| 层 | 条数 | 内容 | 状态 |
|---|---|---|---|
| **P0** | 26 + 语言自身 3 | 顶部/底部导航 5、通用按钮 5、Home 空状态 2、连接表单标签 4、设置页外观段 4、文字大小卡 3、App 标题 1、错误重试 1、语言卡片自身 | ✅ 本期完成 |
| **P1** | ≈60 | 聊天主路径（`chat_screen.dart` 的动作/错误/气泡署名）、主要弹窗（`gateway_approval_dialog`、`gateway_clarify_dialog`、`share_text_review_sheet`、`config_backup_card`）、`workspace_screen.dart` 的 Inbox/New/Search | ⏳ 下一批 |
| **P2** | ≈430 | `session_list_screen`、`project_detail_screen`、`cron_screen`、`files_screen`、`skills_screen`、`memory_screen`、`more_pane`、`projects_pane` 的长文案与 hint | ⏳ 按「一屏一 PR」推进 |

P0 之后，P1/P2 界面**仍然是英文**——这是有意识的交付切分，PR description 里必须写明，
否则用户会以为语言切换坏了。

## 4. 语言行为定义

- **首次启动**（`app_language_preference` 不存在）= 跟随 Android 系统语言。
  实现方式：`AppLanguage.system.locale` 返回 `null`，`MaterialApp.locale` 交给 Flutter
  默认解析（`basicLocaleListResolution`），比手写 `languageCode == 'zh'` 判断更能扛住
  分屏、per-app language、运行中切换系统语言。
- **显式选择** = `en` 或 `zh`，写 `SharedPreferences`，值 `system` / `en` / `zh`。
- **切换即时生效**，无需重启：`HermesAppState.setAppLanguage()` 存盘后
  `setState(() {})`，整棵 `MaterialApp` 重建，`AppStringsScope` 换新实例。
  副作用与切换主题一致：当前 route 重建，未提交的输入框草稿丢失。
- **key 命名**：`app_language_preference`，与 `app_text_size_preference`、`theme_mode`
  同一命名族。

## 5. `HermesDestination.label` 冻结为英文

`label` 是**稳定标识**：`test/hermes_shell_test.dart` 断言 5 个 label 互异且非空，
`test/workspace_screen_test.dart` L890 直接用 `HermesDestination.more.label` 做查找，
仓库文档也把它当契约引用。本地化它 = 无谓地打破与显示语言无关的契约。

做法：保留 `label`，新增 `localizedLabel(AppStrings strings)`，只有渲染出的
`NavigationBar` / `NavigationRail` 读后者。**后续 PR 不要改 `label`。**

## 6. 已被验证的运行时行为（UX 复查结论）

UX 复查提出了三个「会不会咬人」的问题，其中两个当时只能推断。都已用测试锁定，结论如下。

### 6.1 切换语言不会断流、不会丢状态

`HermesAppState.setState` 重建的是 `MaterialApp` 本身，而 `HomeScreen` 是同一个
widget 类型、没有变化的 `Key` —— Flutter 因此复用 element，`HomeScreenState`、
`ConnectionManager`、`GatewayTurnApplicationController` 保持**同一个对象**。
后者持有活跃的 turn 流。

`test/app_language_rebuild_safety_test.dart` 断言切换语言后三者 `same(...)` 不变。
这与切换主题的行为完全一致（`_ThemeToggle._setMode` 走同一路径）。

推论：我的 PR description 里原本写的「当前 route 重建、未提交的 composer 草稿丢失」
是**过度警告** —— 只有当你切换语言时正停留在 Settings 之外的某个已入栈 route 上，
该 route 才会重建。Settings 页面自身切换时不丢任何东西。

### 6.2 Cinzel 不会挡住中文字形，无需回退链

 Cinzel 只出现在 4 个 brand wordmark / 标题调用点（`lib/main.dart` L193、L904，
`lib/core/screens/session_list_screen.dart` L812、L859），全局 text theme
里唯一的 `fontFamily` 是 `mono`（`hermes_theme.dart` L112–113），**没有全局拉丁字体族**。
所以中文走平台字体，不需要 `fontFamilyFallback`。

`test/chinese_glyph_render_test.dart` 把 10 条中文串放进 widget 树并断言零 layout 异常，
200% 缩放 + 320dp 下同样零异常。这是结构性守卫：将来若有人把 Cinzel 提成全局
`ThemeData.fontFamily`，这两个测试会开始抛异常，而不是静默退化成方框。

### 6.3 Semantics 已按语言变化

卡片 `Semantics.label` 是 `'${strings.language}: $selected'`，所以中文界面读作
`语言：简体中文`（`AppStringsZh.languageAccessibilityLabel` 正是为此而设）。
屏幕阅读器按当前语言播报，不会读错发音。

## 7. 保持英文不自译的词

`Hermes`、`Gateway`、`API Server`、`API Key`、`Android`、`Bearer`、`Cron`、`SSE`、
`URL`、`Dashboard`、`Provider`、`Model`—— 中文界面里照原样保留。语言档位名
（`English` / `简体中文`）用各自语言的自称（endonym），在两种界面语言下都显示原样，
否则中文用户要在中文界面里认一个英文词。
