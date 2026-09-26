import 'package:flutter/widgets.dart';
/// The app's user-visible strings, resolved per interface language.
///
/// This is a hand-written contract rather than `flutter gen-l10n` output, on
/// purpose: the app has two languages whose entire catalogue is short labels
/// with no plural rules, and adding `flutter_localizations` would mean a
/// `pubspec.yaml` change (a new dependency and a regenerated `pubspec.lock`)
/// that this repo's release pipeline treats as a versioned change. See
/// `docs/i18n-scope-decision.md` for the trade-off and the migration trigger.
///
/// **Contract rules** (enforced by `test/app_strings_test.dart`):
/// - every getter is overridden on both implementations;
/// - [AppStringsEn] is byte-identical to the strings that used to be hardcoded,
///   so an English user's screens do not change at all;
/// - language names are endonyms — `English` and `简体中文` stay in their own
///   script in *both* languages, because they identify a language rather than
///   translate a label.
abstract class AppStrings {
  const AppStrings();

  /// Reads the strings installed by the nearest [AppStringsScope].
  ///
  /// Falls back to English when no scope is installed, so a widget pumped
  /// inside a bare `MaterialApp` still renders real text instead of crashing.
  static AppStrings of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppStringsScope>();
    return scope?.strings ?? const AppStringsEn();
  }

  // ---- App chrome ----

  /// Application name.
  String get appTitle;

  /// Settings screen app-bar title.
  String get settings;

  /// Settings → Appearance section header.
  String get appearance;

  // ---- Top-level navigation ----

  /// `HermesDestination.home`.
  String get navHome;

  /// `HermesDestination.chats`.
  String get navChats;

  /// `HermesDestination.projects`.
  String get navProjects;

  /// `HermesDestination.activity`.
  String get navActivity;

  /// `HermesDestination.more`.
  String get navMore;

  // ---- Common actions ----

  /// Dismisses a dialog or sheet without applying anything.
  String get commonCancel;

  /// Commits a form.
  String get commonSave;

  /// Commits an edit to an existing item.
  String get commonSaveChanges;

  /// Destructive confirmation on a connection row.
  String get commonDelete;

  /// Opens a connection for editing.
  String get commonEditConnection;

  /// Submits the connection form.
  String get commonConnect;

  /// Adds a new gateway connection.
  String get commonAddConnection;

  /// Re-applies a saved configuration backup.
  String get commonRestoreConfiguration;

  /// Re-runs a failed load.
  String get commonRetry;

  // ---- Home empty state ----

  /// Headline shown when no gateway is configured yet.
  String get homeNoConnections;

  /// Explains how to add the first gateway.
  String get homeNoConnectionsHint;

  // ---- Connection form ----

  /// Connection name field.
  String get connectionLabel;

  /// Gateway host field.
  String get connectionHost;

  /// Gateway port field.
  String get connectionPort;

  /// Bearer token field.
  String get connectionApiKey;

  // ---- Settings: text size ----

  /// `TextSizeSettingsCard` title and picker title.
  String get settingsTextSize;

  /// `TextSizeSettingsCard` preview row label.
  String get settingsPreview;

  /// Explains what an explicit text-size choice does.
  String get settingsTextSizeDescription;

  /// Explains that the System choice leaves the OS scaler untouched.
  String get settingsTextSizeSystemDescription;

  /// Body copy under the preview row.
  String get settingsTextSizePreviewBody;

  // ---- Settings: theme ----

  /// Theme mode that follows the OS.
  String get themeSystem;

  /// Dark theme.
  String get themeDark;

  /// Light theme.
  String get themeLight;

  // ---- Settings: language ----

  /// The language card title and picker title.
  String get language;

  /// Explains that a language change applies immediately.
  String get languageSheetDescription;

  /// Subtitle of the "follow the Android system language" row.
  String get languageSubtitleSystem;

  /// Subtitle of a row that pins one specific language.
  String get languageSubtitleExplicit;

  /// Row label for English. Endonym: identical in both interface languages,
  /// so an English reader of a Chinese UI still recognises the row.
  String get languageEnglish;

  /// Row label for Simplified Chinese. Endonym: identical in both interface
  /// languages.
  String get languageChinese;

  // ---- Settings: Profile default model ----

  /// Settings section header.
  String get settingsProfileDefaultModel;

  /// Section explanation: what changing this affects.
  String get settingsProfileDefaultModelDescription;

  /// Label above the resolved provider/model line.
  String get settingsCurrentProfileDefault;

  /// `Context: N tokens`.
  String get settingsContextTokens;

  /// Button that sets the current model as the profile default.
  String get settingsSetProfileDefault;

  /// The provider picker's label.
  String get settingsProvider;

  /// The model picker's label.
  String get settingsModel;

  // ---- Settings: Voice ----

  /// Section header, and the TTS dropdown's label.
  String get settingsVoice;

  /// Dropdown row meaning "no explicit choice".
  String get settingsVoiceAuto;

  /// Empty state when the device exposes no TTS voices.
  String get settingsVoiceNoneFound;

  // ---- Settings: Verbose mode ----

  /// ListTile title.
  String get settingsVerboseMode;

  /// ListTile subtitle.
  String get settingsVerboseModeDescription;

  // ---- Settings: About ----

  /// Section header.
  String get settingsAbout;

  /// Section header for the session-source filter.
  String get settingsSessionSources;

  /// Section header for the connection card.
  String get settingsConnection;

  /// Section header for backup and restore.
  String get settingsBackupRestore;

  /// The product name shown above the version line.
  String get settingsAboutProduct;

  /// One-line product description.
  String get settingsAboutDescription;

  /// `Version x.y.z`. Receives the version name; the digits are never
  /// localised.
  String get settingsVersion;

  /// Error line shown when package info could not be read.
  String get settingsLoadFailed;

  /// App bar refresh action.
  String get commonRefresh;

  // ---- Settings: Backup & restore ----

  /// The card's own title. Same wording as [settingsBackupRestore]; the card
  /// repeats it because it is also reachable from elsewhere.
  String get backupTitle;

  /// Card explanation of what a backup is.
  String get backupDescription;

  /// Export button.
  String get backupExport;

  /// Import button.
  String get backupImport;

  /// Title of the export passphrase sheet.
  String get backupProtectTitle;

  /// Explanation above the passphrase field in the export sheet.
  String get backupProtectDescription;

  /// Passphrase field label, in both sheets.
  String get backupPassphrase;

  /// Passphrase confirmation field label, export sheet only.
  String get backupConfirmPassphrase;

  /// Title of the restore sheet.
  String get backupRestoreTitle;

  /// Merge strategy row: title and description.
  String get backupMerge;

  /// Merge strategy description.
  String get backupMergeDescription;

  /// Replace strategy row: title and description.
  String get backupReplace;

  /// Replace strategy description.
  String get backupReplaceDescription;

  /// Restore button in the restore sheet.
  String get backupRestore;

  /// Sheet-level cancel action.
  String get backupCancel;

  /// Visibility toggle tooltip when the passphrase is currently hidden.
  String get backupShowPassphrase;

  /// Visibility toggle tooltip when the passphrase is visible.
  String get backupHidePassphrase;
}

/// English strings.
///
/// Every value here is character-for-character the string that previously
/// lived inline at the call site. That is the mechanism that keeps this change
/// invisible to English users, and it is what `test/app_strings_test.dart`
/// asserts.
class AppStringsEn extends AppStrings {
  const AppStringsEn();

  @override
  String get appTitle => 'Hermes Agent';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get navHome => 'Home';

  @override
  String get navChats => 'Chats';

  @override
  String get navProjects => 'Projects';

  @override
  String get navActivity => 'Activity';

  @override
  String get navMore => 'More';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonSaveChanges => 'Save Changes';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEditConnection => 'Edit Connection';

  @override
  String get commonConnect => 'Connect';

  @override
  String get commonAddConnection => 'Add Connection';

  @override
  String get commonRestoreConfiguration => 'Restore configuration';

  @override
  String get commonRetry => 'Retry';

  @override
  String get homeNoConnections => 'No connections';

  @override
  String get homeNoConnectionsHint =>
      'Tap + to add a remote Hermes Gateway\n(API Server, port 8642)';

  @override
  String get connectionLabel => 'Label';

  @override
  String get connectionHost => 'Host';

  @override
  String get connectionPort => 'Port';

  @override
  String get connectionApiKey => 'API Key';

  @override
  String get settingsTextSize => 'Text size';

  @override
  String get settingsPreview => 'Preview';

  @override
  String get settingsTextSizeDescription =>
      'Explicit choices adjust Android accessibility text size; '
      'System leaves it unchanged.';

  @override
  String get settingsTextSizeSystemDescription =>
      'Use Android accessibility text size exactly.';

  @override
  String get settingsTextSizePreviewBody =>
      'Hermes keeps Android accessibility text scaling active.';

  @override
  String get themeSystem => 'System';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get language => 'Language';

  @override
  String get languageSheetDescription =>
      'Interface language. Changes apply immediately.';

  @override
  String get languageSubtitleSystem => 'Follow the system language';

  @override
  String get languageSubtitleExplicit => 'Interface language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '简体中文';

  @override
  String get settingsProfileDefaultModel => 'Profile default model';

  @override
  String get settingsProfileDefaultModelDescription =>
      'Changes the default for {0}. Use the selector in a chat to override '
      'only that conversation.';

  @override
  String get settingsCurrentProfileDefault => 'Current profile default';

  @override
  String get settingsContextTokens => 'Context: {0} tokens';

  @override
  String get settingsSetProfileDefault => 'Set profile default';

  @override
  String get settingsProvider => 'Provider';

  @override
  String get settingsModel => 'Model';

  @override
  String get settingsVoice => 'Voice';

  @override
  String get settingsVoiceAuto => 'Auto (device default)';

  @override
  String get settingsVoiceNoneFound =>
      'No TTS voices found.\n'
      'Install Google Text-to-Speech and download voice data.';

  @override
  String get settingsVerboseMode => 'Verbose Mode';

  @override
  String get settingsVerboseModeDescription =>
      'Show tool calls, thinking, and message metadata';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsSessionSources => 'Session Sources';

  @override
  String get settingsConnection => 'Connection';

  @override
  String get settingsBackupRestore => 'Backup & restore';

  @override
  String get settingsAboutProduct => 'Hermes Agent for Android';

  @override
  String get settingsAboutDescription =>
      'Browse and manage your Hermes Agent sessions from your phone. '
      'Connects to a Hermes dashboard running on your local network.';

  @override
  String get settingsVersion => 'Version {0}';

  @override
  String get settingsLoadFailed => 'Failed to load settings';

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get backupTitle => 'Backup & restore';

  @override
  String get backupDescription =>
      'Save your connections and settings to an encrypted file, then restore '
      'them after reinstalling or on another device.';

  @override
  String get backupExport => 'Export';

  @override
  String get backupImport => 'Import';

  @override
  String get backupProtectTitle => 'Protect this backup';

  @override
  String get backupProtectDescription =>
      'The file contains your API keys and dashboard password, so it is '
      'encrypted. Without this passphrase the backup cannot be restored.';

  @override
  String get backupPassphrase => 'Passphrase';

  @override
  String get backupConfirmPassphrase => 'Confirm passphrase';

  @override
  String get backupRestoreTitle => 'Restore configuration';

  @override
  String get backupMerge => 'Merge';

  @override
  String get backupMergeDescription =>
      'Add and update connections from the backup, keep the rest.';

  @override
  String get backupReplace => 'Replace';

  @override
  String get backupReplaceDescription =>
      'Delete connections that are not in the backup.';

  @override
  String get backupRestore => 'Restore';

  @override
  String get backupCancel => 'Cancel';

  @override
  String get backupShowPassphrase => 'Show passphrase';

  @override
  String get backupHidePassphrase => 'Hide passphrase';
}

/// Simplified Chinese strings.
///
/// Terminology follows Android/Material Chinese conventions and the glossary
/// in `docs/i18n-glossary.md`. Technical identifiers (`Hermes`, `Gateway`,
/// `API Server`, `Android`) are deliberately kept in their original form.
class AppStringsZh extends AppStrings {
  const AppStringsZh();

  @override
  String get appTitle => 'Hermes Agent';

  @override
  String get settings => '设置';

  @override
  String get appearance => '外观';

  @override
  String get navHome => '首页';

  @override
  String get navChats => '会话';

  @override
  String get navProjects => '项目';

  @override
  String get navActivity => '动态';

  @override
  String get navMore => '更多';

  @override
  String get commonCancel => '取消';

  @override
  String get commonSave => '保存';

  @override
  String get commonSaveChanges => '保存修改';

  @override
  String get commonDelete => '删除';

  @override
  String get commonEditConnection => '编辑连接';

  @override
  String get commonConnect => '连接';

  @override
  String get commonAddConnection => '添加连接';

  @override
  String get commonRestoreConfiguration => '恢复配置';

  @override
  String get commonRetry => '重试';

  @override
  String get homeNoConnections => '暂无连接';

  @override
  String get homeNoConnectionsHint => '点按 + 添加远程 Hermes 网关\n（API Server，端口 8642）';

  @override
  String get connectionLabel => '名称';

  @override
  String get connectionHost => '主机';

  @override
  String get connectionPort => '端口';

  @override
  String get connectionApiKey => 'API 密钥';

  @override
  String get settingsTextSize => '文字大小';

  @override
  String get settingsPreview => '预览';

  @override
  String get settingsTextSizeDescription =>
      '显式选择会调整 Android 无障碍文字大小；跟随系统则保持原样。';

  @override
  String get settingsTextSizeSystemDescription => '完全沿用 Android 无障碍文字大小。';

  @override
  String get settingsTextSizePreviewBody => 'Hermes 保持 Android 无障碍文字缩放生效。';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeDark => '深色';

  @override
  String get themeLight => '浅色';

  @override
  String get language => '语言';

  @override
  String get languageSheetDescription => '界面语言，更改立即生效。';

  @override
  String get languageSubtitleSystem => '跟随系统语言';

  @override
  String get languageSubtitleExplicit => '界面语言';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '简体中文';

  @override
  String get settingsProfileDefaultModel => '个人资料默认模型';

  @override
  String get settingsProfileDefaultModelDescription =>
      '更改 {0} 的默认模型。在某个会话里用选择器可只覆盖该会话。';

  @override
  String get settingsCurrentProfileDefault => '当前个人资料默认值';

  @override
  String get settingsContextTokens => '上下文：{0} tokens';

  @override
  String get settingsSetProfileDefault => '设为个人资料默认';

  @override
  String get settingsProvider => '服务提供商';

  @override
  String get settingsModel => '模型';

  @override
  String get settingsVoice => '语音';

  @override
  String get settingsVoiceAuto => '自动（设备默认）';

  @override
  String get settingsVoiceNoneFound => '未找到 TTS 语音。\n请安装 Google 文字转语音并下载语音数据。';

  @override
  String get settingsVerboseMode => '详细模式';

  @override
  String get settingsVerboseModeDescription => '显示工具调用、思考过程和消息元数据';

  @override
  String get settingsAbout => '关于';

  @override
  String get settingsSessionSources => '会话来源';

  @override
  String get settingsConnection => '连接';

  @override
  String get settingsBackupRestore => '备份与恢复';

  @override
  String get settingsAboutProduct => 'Hermes Agent for Android';

  @override
  String get settingsAboutDescription =>
      '在手机上浏览和管理你的 Hermes Agent 会话，连接到本地网络上的 Hermes dashboard。';

  @override
  String get settingsVersion => '版本 {0}';

  @override
  String get settingsLoadFailed => '设置加载失败';

  @override
  String get commonRefresh => '刷新';

  @override
  String get backupTitle => '备份与恢复';

  @override
  String get backupDescription =>
      '把连接和设置保存到加密文件，重装或换设备后再恢复。';

  @override
  String get backupExport => '导出';

  @override
  String get backupImport => '导入';

  @override
  String get backupProtectTitle => '保护此备份';

  @override
  String get backupProtectDescription =>
      '该文件包含你的 API 密钥和 dashboard 密码，因此会加密。'
      '没有这个口令就无法恢复备份。';

  @override
  String get backupPassphrase => '口令';

  @override
  String get backupConfirmPassphrase => '确认口令';

  @override
  String get backupRestoreTitle => '恢复配置';

  @override
  String get backupMerge => '合并';

  @override
  String get backupMergeDescription => '添加并更新备份中的连接，保留其余连接。';

  @override
  String get backupReplace => '替换';

  @override
  String get backupReplaceDescription => '删除不在备份中的连接。';

  @override
  String get backupRestore => '恢复';

  @override
  String get backupCancel => '取消';

  @override
  String get backupShowPassphrase => '显示口令';

  @override
  String get backupHidePassphrase => '隐藏口令';
}

/// Publishes the resolved [AppStrings] to a subtree.
///
/// Installed once by `MaterialApp.builder` in `main.dart`, so every screen —
/// including one reached through a route pushed before a language switch —
/// rebuilds with new strings when the user picks a different language.
class AppStringsScope extends InheritedWidget {
  const AppStringsScope({required this.strings, required super.child, super.key});

  /// The strings for the current interface language.
  final AppStrings strings;

  @override
  bool updateShouldNotify(AppStringsScope oldWidget) =>
      oldWidget.strings != strings;
}
