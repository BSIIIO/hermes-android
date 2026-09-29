# 机器人迭代会话总览（2026-09-29）

本文件是**状态快照与续作指引**，不是流水账。上一份见
`docs/i18n-session-2026-09-27.md`；术语对照 `docs/i18n-glossary.md`，
签名链路 `docs/release-signing.md`。

主仓：`github.com/BSIIIO/hermes-android`（fork，main 受我们控制）
本地：`/vol2/@appdata/trim.hermes/workspace/hermes-android-audit`

---

## 1. 当前状态（一句话）

**机器人从「更多」提到主菜单第 4 格（与「动态」对调），头像换成桌面版那个会动的
脸，v2.1.9 装机验证双标题栏已修。两个迭代 + 一次装机反馈全部闭环。**

| 项 | 值 |
|---|---|
| main HEAD | `317712e`（chore(release): bump to v2.1.9） |
| Release | `v2.1.9`，tag `317712e`，https://github.com/BSIIIO/hermes-android/releases/tag/v2.1.9 |
| pubspec | `2.1.9+2149`（arm64 split 21492 > 升级地板 2127） |
| 测试 | 99 个文件 / 1214 项，本地全过；CI `Analyze & Test` success |
| 装机验证 | 用户已测，导航与头像通过；v2.1.8 的双层标题栏已在 v2.1.9 修掉 |

### 这次做了什么

| PR / commit | 内容 |
|---|---|
| #28 `d220449` | 迭代 1：机器人入口提到主菜单，动态进「更多」（对调） |
| #28 `d220449` | 迭代 2：`bot_avatar_face.dart` 移植桌面过程式脸 + 动效 |
| `6451cca` | bump v2.1.8（首个含两迭代的装机包） |
| `c2f4348` | 装机反馈：去掉机器人页第二层标题栏 |
| `317712e` | bump v2.1.9 |

### 导航结构的现在

- `HermesDestination`：`home, chats, projects, bots, more`。
  **enum 顺序即显示顺序**——shell 是 index-driven（`_current.index`），
  中间插入会静默错位。
- 机器人面板是**内嵌** `_BotsPane`（非 push 路由），由 IndexedStack 常驻，
  切页不丢滚动位置与已加载数据。
- 动态从「更多」点开是 **push**（它已不是 destination），用的 `Scaffold` +
  `AppBar` 是对的——它不在 shell 里。
- 动态的 blocked 角标随格位消失，改接到首页「收件箱」按钮（同一数据源）。

---

## 2. Bot Mode 头像：为什么是过程式的，不是存储的 PNG

这是本次最反直觉的一点，值得先记住结论：

**线上 gateway 的 17 个 profile，头像全部是 160×160 的栅格图，不是照片。**

那是 desktop 自己为 agent 间通知推回去的（`isBackfilledFacePng`），且 desktop
**故意不在列表里渲染它**——烤成 PNG 就不能动了。所以：

- 直接显示存储的字节 → 每张脸冻结在某一帧，**动效直接消失**，而"要确保动效可用"
  正是需求本身。
- 正确做法 = 移植桌面 `apps/desktop/src/plugins/hermes-bots/avatar.tsx` 的
  过程式绘制，把存储字节只在**真照片**时使用。

判定真照片：`imageKind == 'photo'` **或** PNG IHDR 宽高不是 160×160。
`has_avatar: true` 单独**绝不**作为照片依据（17 个 profile 全带这个字段）。

### 移植值的真伪（都经 Python 复算桌面源码确认）

| 项 | 值 | 坑 |
|---|---|---|
| 轮廓点数 | 52 | 但 **cloud 强制 `n = max(64, steps)`** 后按弧长拆分；drop 是 cubic(n)+arc(n+1)+cubic(n)，默认步数下巧合也 = 52 |
| shape 派生 | `hashString(name) % 8` | picker 顺序 `['circle','blob','squircle','pill','triangle','hexagon','cloud','drop']`，**blob 是第二个**（读 wire 值容易弄反） |
| 颜色派生 | `hash % 360`，68% sat / 58% light | `(hash*31 + char) >>> 0` |
| idle 摆动 | `sin(t*0.5)*1.5` turn | **idle 根本不眨眼** |
| working 倾斜 | turn 中心 **-11**（`-11 + sin(t*0.48)*8`） | 加 gazeY -1.6 + 三点 |
| 眨眼 | `(t % 1.45) > 1.26` | **只有 work / think** |
| 眼睛 x | 15.4 / 24.6，y 17.2 | **cloud 脸型 y 是 22**（身体更低） |
| 瞳孔反色 | 亮度 < 110 时翻亮 | 0.2126R+0.7152G+0.0722B（0-255） |
| 三角形轮廓 | y 到 **-3.21**，超出 40×40 盒子 | **桌面自己就这样**（解析环比兜底 SVG 路径宽，SVG 带 overflow visible）。"修"它 = 与桌面失同步 |

### 动效：一个时钟，不是每脸一个

`BotFaceClock` 是单例 `Ticker`，等价桌面单一 `requestAnimationFrame` 循环。
每张脸从时钟的 elapsed 推导姿态，所以：

- 别处 `setState` 是**相位校正**而非重置——否则一屏的脸会集体从零开始摇。
- 每脸独立 ticker 会在几秒内漂移，一列脸各自摇摆。
- 最后一张脸卸载时 ticker dispose（`isActive`）。

---

## 3. 教训（这账单是花钱买来的）

### 3.1 装了机才知道的问题：destination 不能自带 AppBar

v2.1.8 装机反馈「两个标题栏两个返回按钮」。根因：`BotsScreen` 还是被 push 路由
时的结构，自带 `Scaffold` + `AppBar`；变成 primary destination 后 shell 已经有一层。

**判断规则**：一个 pane 若由 shell 托管（IndexedStack 常驻），它**不能**带
`AppBar`；若它是被 `_push()` 的独立页面，它**必须**带（否则没有标题栏）。
本次两个都对了：`_BotsPane` 内嵌无 AppBar，Activity 走 push 带 Scaffold。

删 Scaffold 时**注意 backgroundColor 别一起丢**：不自己上色会继承最近 Material 的
`canvasColor`，本主题从不覆盖它，M3 种子默认在亮暗两模式下都接近黑（历史 bug 就是
浅色模式黑菜单）。用 `ColoredBox` 保住底色，不把 bar 带回来。

### 3.2 有动效的页面，`pumpAndSettle` 永远超时

`bots_screen_test.dart` 里两处 `pumpAndSettle` 在脸上线后必然超时——动画不停，就没有
静止帧可 settle。改用 `tester.pump(duration)`。这是**预期行为不是 flake**。

配套：共享时钟单例**跨 `testWidgets` 会残留**，所以「时钟会停」这个测试必须在
**同一个测试内** mount → assert → unmount → assert，别依赖上个测试的 teardown。

### 3.3 Dart 的坑（移植 JS 数学时集中爆发）

| 现象 | 真相 |
|---|---|
| `math.floor` 不存在 | `dart:math` 没有顶层 floor——用 `(v+0.5).floorToDouble()` |
| `Math.round` 不等于 Dart `round()` | JS 是半值向 **+∞**，Dart 是远离零。负参数时 hexagon 顶点会落到错误扇区 |
| `parse(a ?? b)` 里 `a` 是 `String?`、`b` 是 enum | 静默拓宽成 `Object`，编译不过 |
| `test/` 里写 `../lib/...` | 触发 `avoid_relative_lib_imports`，要用 `package:hermes_android/...` |
| `p.x` 取不到命名 record 字段 | Dart 3 命名 record 用 `.x`/`.y`（`$1`/`$2` 只在位置字段） |

### 3.4 后台探针会在修复后补报旧失败

`terminal(background=true, notify_on_complete=true)` 启的探针，**修完还会跑完并
把旧失败当新回归报出来**——本次踩了两次。判据一条命令：
`git log --oneline -1` 对 HEAD，再单独重跑那个测试；HEAD 是自己的提交且测试过，
通知描述的就是已不存在的代码。

### 3.5 「测试改绿」要分开看：哪些是真松了，哪些是代码错了

本次改了 3 处测试，都不是为了让它绿而松，而是**原断言锁的是旧结构**：

- `bots_screen_test.dart` 两处底色断言：原要找 `Scaffold` 才能断言，Scaffold 删了
  之后契约仍在（底色仍是回归风险），改成经 `ColoredBox` 断言同一件事。
- `pumpAndSettle`：如上，动画不停是特性。
- 三角环越界 / 点数非 52：把桌面真实行为钉住，而不是把移植"修"坏。

反过来，`expect(find.byType(AppBar), findsOneWidget)` 那条是**真的该删**——它锁的
正是本次要消除的东西。判断标准：**断言的是"需求"，还是"上一次的写法"？**

---

## 4. 发布口径（这次踩到的 tag 时序）

`v2.1.7` 的 tag 打在 `7fb36ba`，**在 PR #28 合入之前**——所以线上已发布的 v2.1.7
**不含**这两个迭代。设备上装 v2.1.7 测这两个功能，结论无效。

**规则**：发版前先 `git ls-remote --tags origin` 看最新 tag 指向哪个 commit，
再决定 bump 还是 dispatch。当一个 feature 已合进 main、但当前版本的 tag 打在合并
之前，**只有正式 bump 版本**能让 tag 对上 main；光 dispatch 同一个 commit 出的包
会让装机者以为是新功能，实际没有。

四处版本号必须同步（`release_identity_test.dart` 断言它们一致）：

1. `pubspec.yaml` `version: X.Y.Z+NNNN`
2. `.github/workflows/pr-quality.yml` `REQUIRED_BASE_VERSION_CODE`
3. `.github/workflows/release.yml` 同项
4. `test/release_identity_test.dart`，含派生 arm64 `NNNN*10+2`

升级地板 `android/app/build.gradle.kts` 是 2127，bump 必须高于它。

---

## 5. 下一步（如果继续做）

| 方向 | 说明 |
|---|---|
| working 姿态接线 | 现在 roster 恒为 `BotFaceMood.idle`（脸只是轻摇）。驱动 working 的是每个 bot 的运行状态，与 blocked count 同源，接上后工作中会倾身 + 三点跳动 |
| 宠物精灵 | `BotAvatarKind.pet` 已留位未实现：spritesheet 是 1536×1872 webp，桌面要 fetch + 裁切 |
| `botsTitle`/`botsSubtitle` | 已从 `more_pane.dart` 退役，但字符串仍留在 `app_strings.dart`（现在作为面板内标题用，未变孤儿） |
| 头像真照片路径 | 已实现但**线上无样本**（17 个全是栅格），`imageKind: photo` 分支尚未被真实数据验证过 |

---

## 6. 相关文档与探针

- 桌面脸源：`apps/desktop/src/plugins/hermes-bots/avatar.tsx`（NousResearch/hermes-agent）
- 本地探针：`workspace/probes/probe_avatar_sync.py`（17 个全 160×160 的证据）、
  `probe_bot_ui_meta.py`（`ui_meta['hermes-bots']` 的 shape/color）
- 测试：`test/bot_avatar_face_test.dart`（28 项，钉移植值）
- 复盘经验已同步进 skill `hermes-android-repo`
