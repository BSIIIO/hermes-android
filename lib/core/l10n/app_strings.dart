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
    final scope = context.dependOnInheritedWidgetOfExactType<AppStringsScope>();
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

  // ---- Chats: drawer navigation (P1 batch 2) ----

  /// Drawer: the profile row's label.
  String get drawerProfile;

  /// Drawer: sub-label under the profile row, naming the active profile.
  String get drawerProfileAction;

  /// Drawer: Spaces entry.
  String get drawerSpaces;

  /// Drawer: Workspace entry.
  String get drawerWorkspace;

  /// Drawer: Workspace entry's subtitle.
  String get drawerWorkspaceSubtitle;

  /// Drawer: Memory entry.
  String get drawerMemory;

  /// Drawer: Cron Jobs entry.
  String get drawerCronJobs;

  /// Drawer: Skills entry.
  String get drawerSkills;

  /// Drawer: Settings entry.
  String get drawerSettings;

  // ---- Chats: list states (P1 batch 2) ----

  /// Shown while the gateway connection is being established.
  String get chatsConnecting;

  /// Hint under [chatsConnecting]; a shell command the user can run.
  String get chatsConnectingHint;

  /// Title of the screen shown when the gateway is unreachable.
  String get chatsConnectionIssue;

  /// Shown when the session list is empty.
  String get chatsNoSessions;

  /// Hint under [chatsNoSessions].
  String get chatsNoSessionsHint;

  /// Row meta line: message count, model, and time.
  String get chatsRowMeta;

  // ---- Chats: actions and dialogs (P1 batch 2) ----

  /// Tooltip/menu item that starts a new chat.
  String get chatsNewChat;

  /// Menu item that switches the active profile.
  String get chatsSwitchProfile;

  /// Menu item that renames a chat.
  String get chatsRenameChat;

  /// The confirm button in the rename dialog.
  String get chatsRename;

  /// Menu item that branches a chat.
  String get chatsBranchChat;

  /// Menu item that deletes a session.
  String get chatsDelete;

  /// Menu item that moves a chat to another space.
  String get chatsMoveToSpace;

  /// Title of the move-chat sheet.
  String get chatsMoveChat;

  /// Description under [chatsMoveChat].
  String get chatsMoveChatChoose;

  /// The `Unassigned` destination row.
  String get chatsMoveUnassigned;

  /// Confirmation title before deleting a session.
  String get chatsDeleteSessionTitle;

  /// Confirmation body; receives the session title.
  String get chatsDeleteSessionBody;

  /// Snackbar confirming a delete.
  String get chatsSessionDeleted;

  /// Snackbar title shown above the menus.
  String get chatsActions;

  /// Placeholder used when a session's title is blank.
  String get chatsUntitledSession;

  // ---- Chats: profile, search, and prompts (P1 batch 2) ----

  /// Menu item that switches the active profile.
  String get chatsProfile;

  /// Snackbar confirming a session was renamed.
  String get chatsRenamePrompt;

  /// Snackbar confirming a branch was created.
  String get chatsBranchCreated;

  /// Snackbar after deleting a session.
  String get chatsDeleted;

  /// Error snackbar template; receives the error text.
  String get chatsDeleteFailed;

  /// Error snackbar template for a failed rename.
  String get chatsRenameFailed;

  /// Tooltip that clears the search field.
  String get chatsClearSearch;

  /// Menu item that changes which model rewrites AI searches.
  String get chatsChangeAiSearchModel;

  /// Label of the search-mode control.
  String get chatsSearchMode;

  /// Placeholder for the AI search tier.
  String get chatsSearchHintAi;

  /// Placeholder for the full-text search tier.
  String get chatsSearchHintFullText;

  /// Placeholder for the loaded-chats tier.
  String get chatsSearchHintLoaded;

  /// On-device search tier: title and description.
  String get chatsSearchOnDevice;

  /// Description of the on-device tier.
  String get chatsSearchOnDeviceDetail;

  /// Full-text search tier: title and description.
  String get chatsSearchFullText;

  /// Description of the full-text tier.
  String get chatsSearchFullTextDetail;

  /// Combined AI + full-text search tier: title.
  String get chatsSearchAiFullText;

  /// Row offering the lower on-device tier.
  String get chatsSearchUseOnDevice;

  /// Shown when a full-text search matched nothing.
  String get chatsSearchNoMatches;

  /// Shown above the query the AI actually searched for.
  String get chatsSearchAiSearchedFor;

  /// The AI-plus-full-text tier's row title.
  String get chatsSearchAiFullTextTitle;

  /// Prompt shown when no AI search model has been chosen yet.
  String get chatsSearchAiChooseModel;

  /// Title of the AI search model sheet.
  String get chatsAiModelTitle;

  /// Explanation under [chatsAiModelTitle].
  String get chatsAiModelDescription;

  /// Error template; receives the failure text.
  String get chatsAiModelLoadFailed;

  /// The disabled header row of the profile picker.
  String get chatsProfileHeader;

  /// Dialog title and confirm label for branching a chat.
  String get chatsBranchChatTitle;

  /// Confirm button in the branch dialog.
  String get chatsBranchCreate;

  // ---- Projects: list (P1 batch 3) ----

  /// Title of the Projects section.
  String get projectsTitle;

  /// Section header for archived projects.
  String get projectsArchived;

  /// Chip marking the currently active project.
  String get projectsActive;

  /// Tooltip and menu title for the per-project action menu.
  String get projectsActions;

  /// Menu item renaming a project.
  String get projectsRename;

  /// Menu item archiving a project.
  String get projectsArchive;

  /// Menu item restoring an archived project.
  String get projectsRestore;

  /// Empty state title.
  String get projectsEmptyTitle;

  /// Empty state message.
  String get projectsEmptyMessage;

  /// Empty state action label.
  String get projectsCreateAction;

  /// FAB tooltip creating a project.
  String get projectsNewProject;

  /// Dialog title creating a project.
  String get projectsNewDialogTitle;

  /// Dialog confirm button creating a project.
  String get projectsCreate;

  /// Text field label for a project name.
  String get projectsNameLabel;

  /// Validation error when the name field is blank.
  String get projectsNameRequired;

  /// Archive confirmation title; receives the project name.
  String get projectsArchiveConfirmTitle;

  /// Archive confirmation body.
  String get projectsArchiveConfirmBody;

  /// Confirm button in the archive dialog.
  String get projectsArchiveConfirmAction;

  /// Rename dialog title; receives the current name.
  String get projectsRenameDialogTitle;

  /// Rename dialog confirm button.
  String get projectsRenameAction;

  /// Error template; receives the verb and the failure text.
  String get projectsMutationFailed;

  /// Verb for the create mutation inside [projectsMutationFailed].
  String get projectsActionCreate;

  /// Verb for the rename mutation inside [projectsMutationFailed].
  String get projectsActionRename;

  /// Verb for the archive mutation inside [projectsMutationFailed].
  String get projectsActionArchive;

  /// Verb for the restore mutation inside [projectsMutationFailed].
  String get projectsActionRestore;

  /// Error state title when the gateway cannot be reached.
  String get projectsUnreachableTitle;

  /// Error state body when the gateway cannot be reached.
  String get projectsUnreachableMessage;

  /// Banner shown while displaying cached projects.
  String get projectsOfflineBanner;

  /// Sub-line under a local space card; receives the chat count.
  String get projectsLocalSpaceSubtitle;

  /// Singular form of the local-space chat count.
  String get projectsOneChat;

  /// Plural form of the local-space chat count; receives the count.
  String get projectsChatCount;

  /// Header of the compatibility-mode fallback.
  String get projectsCompatibilityMode;

  /// Explanation shown under [projectsCompatibilityMode].
  String get projectsCompatibilityExplanation;

  /// Empty state title when no local spaces exist.
  String get projectsNoLocalSpacesTitle;

  /// Empty state message when no local spaces exist.
  String get projectsNoLocalSpacesMessage;

  /// Section header for on-device spaces.
  String get projectsOnThisDevice;

  /// Action on the Projects header reviewing local spaces.
  String get projectsReviewLocalSpaces;

  // ---- Projects: detail (P1 batch 3) ----

  /// Title for the dialog moving a conversation.
  String get projectDetailMoveConversation;

  /// Destination row meaning "no project".
  String get projectDetailUnassigned;

  /// Snackbar after a successful move; receives the destination label.
  String get projectDetailMovedTo;

  /// Snackbar when a move fails.
  String get projectDetailMoveFailed;

  /// Snackbar action retrying a failed operation.
  String get commonRetryShort;

  /// Rename dialog title; receives the project name.
  String get projectDetailRenameTitle;

  /// Rename dialog confirm button.
  String get projectDetailRename;

  /// Archive confirmation title; receives the project name.
  String get projectDetailArchiveConfirmTitle;

  /// Archive confirmation body.
  String get projectDetailArchiveConfirmBody;

  /// Archive confirm button.
  String get projectDetailArchive;

  /// Delete confirmation title; receives the project name.
  String get projectDetailDeleteConfirmTitle;

  /// Delete confirmation body.
  String get projectDetailDeleteConfirmBody;

  /// Delete confirm button.
  String get projectDetailDelete;

  /// Error template for archive / delete; receives the verb.
  String get projectDetailManageFailed;

  /// Snackbar when deleting fails.
  String get projectDetailDeleteFailed;

  /// FAB label starting a new chat inside a project.
  String get projectDetailNewChat;

  /// Section header listing the project's chats.
  String get projectDetailChats;

  /// Card line summarising the project's conversations.
  String get projectDetailConversations;

  /// Section header for repositories.
  String get projectDetailRepositories;

  /// Section header for the project location.
  String get projectDetailLocation;

  /// Section header for the project folders.
  String get projectDetailFolders;

  /// Empty state title for folders.
  String get projectDetailNoFoldersTitle;

  /// Empty state message for folders.
  String get projectDetailNoFoldersMessage;

  /// Error title when the gateway lacks an assets index.
  String get projectDetailAssetsUnavailableTitle;

  /// Error message when the gateway lacks an assets index.
  String get projectDetailAssetsUnavailableMessage;

  /// Empty state title for activity.
  String get projectDetailNoActivityTitle;

  /// Empty state message for activity.
  String get projectDetailNoActivityMessage;

  /// Search field hint inside a project.
  String get projectDetailSearchChats;

  /// Tooltip clearing the project search field.
  String get projectDetailClearSearch;

  /// Empty state title for a project with no chats.
  String get projectDetailNoChatsTitle;

  /// Empty state message for a project with no chats.
  String get projectDetailNoChatsMessage;

  /// Empty state title for a query with no matches; receives the query.
  String get projectDetailNoMatchesTitle;

  /// Empty state message for a query with no matches; receives the query.
  String get projectDetailNoMatchesMessage;

  /// Error title when project chats are unavailable on this gateway.
  String get projectDetailUnsupportedTitle;

  /// Error message when project chats are unavailable on this gateway.
  String get projectDetailUnsupportedMessage;

  /// Error title when the project cannot be opened.
  String get projectDetailOpenFailedTitle;

  /// Error message when the project cannot be opened.
  String get projectDetailOpenFailedMessage;

  /// Banner shown while displaying cached chats.
  String get projectDetailOfflineBanner;

  /// Tab listing the project's overview.
  String get projectDetailTabOverview;

  /// Tab listing the project's folders.
  String get projectDetailTabFiles;

  /// Tab listing the project's assets.
  String get projectDetailTabAssets;

  /// Tab listing the project's activity.
  String get projectDetailTabActivity;

  /// Menu item deleting a project.
  String get projectDetailDeleteProject;

  // ---- Files (P1 batch 4) ----

  /// App bar title of the Files screen.
  String get filesTitle;

  /// Empty directory title.
  String get filesEmptyTitle;

  /// Empty directory message.
  String get filesEmptyMessage;

  /// Chip marking a truncated preview.
  String get filesPreviewTruncated;

  /// Shown when a text preview is unavailable.
  String get filesPreviewUnavailable;

  /// Shown when a binary file cannot be previewed.
  String get filesBinaryPreviewUnavailable;

  /// Download button label.
  String get filesDownload;

  /// Snackbar after a successful download; receives the filename.
  String get filesDownloaded;

  /// Snackbar when a download fails; receives the error.
  String get filesDownloadFailed;

  /// Snackbar after adding a file reference to a chat.
  String get filesAddedToChat;

  /// Button adding a file reference to a chat.
  String get filesAddToChat;

  /// Error title when the file list cannot be read.
  String get filesLoadFailedTitle;

  /// Error title when a preview cannot be read.
  String get filesPreviewFailedTitle;

  /// Error message shared by both failure states.
  String get filesErrorMessage;

  /// Native save dialog title; receives the filename.
  String get filesSaveDialogTitle;

  // ---- Skills (P1 batch 4) ----

  /// App bar title; receives the skill count.
  String get skillsTitle;

  /// Error title when skills cannot be loaded.
  String get skillsLoadFailed;

  /// Empty state title.
  String get skillsEmptyTitle;

  /// Empty state message.
  String get skillsEmptyMessage;

  // ---- Memory (P1 batch 4) ----

  /// App bar title of the Memory screen.
  String get memoryTitle;

  /// Source line under an entry; receives the source label.
  String get memorySource;

  /// Error title when memory cannot be loaded.
  String get memoryLoadFailed;

  /// Empty state title.
  String get memoryEmptyTitle;

  /// Empty state message.
  String get memoryEmptyMessage;

  // ---- Cron (P1 batch 4) ----

  /// App bar title of the Cron screen.
  String get cronTitle;

  /// FAB tooltip and dialog title creating a job.
  String get cronAddJob;

  /// Dialog title editing a job.
  String get cronEditJob;

  /// Name field label in the job editor.
  String get cronNameLabel;

  /// Name field hint.
  String get cronNameHint;

  /// Prompt field label.
  String get cronPromptLabel;

  /// Prompt field hint.
  String get cronPromptHint;

  /// Schedule field label.
  String get cronScheduleLabel;

  /// Schedule field hint.
  String get cronScheduleHint;

  /// FAB tooltip on the job list.
  String get cronAddNewJob;

  /// Toggle meaning a script-backed job needs no agent turn.
  String get cronScriptOnly;

  /// Description under [cronScriptOnly].
  String get cronScriptOnlyHint;

  /// Validation error when required fields are blank.
  String get cronFieldsRequired;

  /// Snackbar after a job is created.
  String get cronJobAdded;

  /// Snackbar after a job is updated.
  String get cronJobUpdated;

  /// Snackbar after a job is deleted; receives the job name.
  String get cronJobDeleted;

  /// Snackbar after a manual trigger.
  String get cronJobTriggered;

  /// Snackbar after resuming a job.
  String get cronJobResumed;

  /// Snackbar after pausing a job.
  String get cronJobPaused;

  /// Menu item triggering a job now.
  String get cronTriggerNow;

  /// Menu item editing a job.
  String get cronEdit;

  /// Menu item deleting a job.
  String get cronDelete;

  /// Confirmation title; receives the job name.
  String get cronDeleteConfirmTitle;

  /// Label shown when a job has never run.
  String get cronNeverRun;

  /// Last-run line; receives the timestamp.
  String get cronLastRun;

  /// Next-run line; receives the timestamp.
  String get cronNextRun;

  /// Error template for all cron operations; receives the failure.
  String get cronOperationFailed;

  /// Error title when the job list cannot be read.
  String get cronLoadFailed;

  /// Pause menu item.
  String get cronPause;

  /// Resume menu item.
  String get cronResume;

  /// Confirm button creating a job.
  String get cronAddAction;

  /// Confirm button saving an edit.
  String get cronSaveAction;

  /// Badge marking a script-backed job.
  String get cronScriptBadge;

  /// Delete confirmation body; receives the job name.
  String get cronDeleteConfirmBody;

  /// Empty state title.
  String get cronEmptyTitle;

  /// Empty state message.
  String get cronEmptyMessage;

  // ---- Spaces (P1 batch 4) ----

  /// App bar title of the Spaces screen.
  String get spacesTitle;

  /// App bar action creating a space.
  String get spacesNewSpace;

  /// Scope tile covering every chat.
  String get spacesAllChats;

  /// Scope tile for chats with no space.
  String get spacesUnassigned;

  /// Action menu title and rename item.
  String get spacesActions;

  /// Menu item renaming a space.
  String get spacesRename;

  /// Hint shown when no space exists yet.
  String get spacesEmptyHint;

  /// Dialog title creating a space.
  String get spacesNewDialogTitle;

  /// Dialog title renaming a space.
  String get spacesRenameDialogTitle;

  /// Name field label in both space dialogs.
  String get spacesNameLabel;

  /// Validation error when the name field is blank.
  String get spacesNameRequired;

  /// Activity subtitle; receives the formatted date.
  String get spacesLastActivity;

  // ---- Workspace shell (P1 batch 4) ----

  /// Title of the Chats pane in the workspace shell.
  String get workspaceChatsTitle;

  /// Error title when the gateway cannot host projects.
  String get workspaceProjectsUnavailableTitle;

  /// Error message when the gateway cannot host projects.
  String get workspaceProjectsUnavailableMessage;

  /// Title of the Inbox route.
  String get workspaceInbox;

  /// FAB label starting a new chat.
  String get workspaceNewChat;

  /// Tooltip opening search across all chats.
  String get workspaceSearchAllChats;

  /// Snackbar when the dashboard cannot be opened.
  String get workspaceDashboardOpenFailed;

  /// Snackbar when a project chat cannot be created.
  String get workspaceProjectChatFailed;

  /// Snackbar retry label.
  String get workspaceRetry;

  /// Snackbar explaining the project-folder fallback.
  String get workspaceProjectFolderFallback;

  /// Snackbar when shared files cannot be prepared.
  String get workspaceSharedFilesFailed;

  // ---- Workspace sessions (P1 batch 4) ----

  /// Error title when conversations cannot be loaded.
  String get workspaceSessionsLoadFailedTitle;

  /// Error message when conversations cannot be loaded.
  String get workspaceSessionsLoadFailedMessage;

  /// Search field hint.
  String get workspaceSessionsSearchHint;

  /// Tooltip clearing the search field.
  String get workspaceSessionsSearchClear;

  /// Meta chip for a conversation with no project.
  String get workspaceSessionsUnassigned;

  /// Tooltip promoting a conversation to a project.
  String get workspaceSessionsPromoteTooltip;

  /// Snackbar after promoting a conversation.
  String get workspaceSessionsPromoted;

  /// Snackbar when promoting fails.
  String get workspaceSessionsPromoteFailed;

  // ---- Chat (P1 batch 5) ----

  /// Snackbar confirming TTS playback started.
  String get chatReadingAloud;

  /// Snackbar when TTS is unavailable.
  String get chatReadAloudUnavailable;

  /// Sheet option capturing a photo.
  String get chatTakePhoto;

  /// Sheet option selecting a remote file.
  String get chatBrowseServerFiles;

  /// Subtitle for the remote-file action.
  String get chatInsertRemoteReference;

  /// Sheet option picking local files.
  String get chatChooseFiles;

  /// Subtitle for the local-file action.
  String get chatLocalFileTypes;

  /// Snackbar when intake registration is deferred.
  String get chatIntakePending;

  /// Sheet title for the model / thinking picker.
  String get chatModelAndThinking;

  /// Subtitle showing the profile default; receives model and provider.
  String get chatProfileDefault;

  /// Generic Cancel action.
  String get chatCancel;

  /// Confirming button of the model picker.
  String get chatApplyToThisChat;

  /// Snackbar when the model list cannot be loaded.
  String get chatModelLoadFailed;

  /// Snackbar confirming a per-chat override; receives model and effort.
  String get chatOverrideApplied;

  /// Snackbar when the model change fails.
  String get chatModelChangeFailed;

  /// Snackbar when a command cannot be denied.
  String get chatDenyFailed;

  /// Snackbar when a Hermes question cannot be skipped.
  String get chatSkipQuestionFailed;

  /// Snackbar when the local close succeeds but the gateway stop fails.
  String get chatStopFailed;

  /// Snackbar when sending fails.
  String get chatSendFailed;

  /// Composer status while the response streams.
  String get chatResponding;

  /// Tooltip on the chat overflow button.
  String get chatActions;

  /// Overflow item refreshing the transcript.
  String get chatRefresh;

  /// Overflow item exporting or sharing.
  String get chatExportShare;

  /// Button dismissing a gateway notification banner.
  String get chatDismiss;

  /// Composer button label; receives the model and scope.
  String get chatModelButton;

  /// Scope shown on the model button when a per-chat override is active.
  String get chatThisChatScope;

  /// Scope shown on the model button when the profile default is used.
  String get chatProfileDefaultScope;

  /// Semantics label of the composer text field.
  String get chatMessageField;

  /// Hint text of the composer.
  String get chatMessageHint;

  /// Semantics label of the voice-reply toggle.
  String get chatSpokenReplies;

  /// Tooltip stopping the in-flight response.
  String get chatStopResponse;

  /// Tooltip sending the drafted message.
  String get chatSend;

  /// Error title when the transcript cannot be loaded.
  String get chatLoadFailedTitle;

  /// Sheet title above the per-message actions.
  String get chatMessageActions;

  /// Snackbar after copying a message.
  String get chatMessageCopied;

  /// Action copying a message.
  String get chatCopyMessage;

  /// Action reading a message aloud.
  String get chatReadAloud;

  /// Action editing and resending a message.
  String get chatEditAndResend;

  /// Action regenerating the last response.
  String get chatRegenerate;

  /// Label for the thinking-effort section of the model sheet.
  String get chatThinkingEffort;

  // ---- Fixups (phone-tested, P1 batch 6) ----

  /// Text-size option that follows Android accessibility exactly.
  String get textSizeSystemLabel;

  /// Description of the System text-size option.
  String get textSizeSystemDescription;

  /// Text-size option: 90%.
  String get textSizeSmallLabel;

  /// Description of the Small text-size option.
  String get textSizeSmallDescription;

  /// Text-size option: 100%.
  String get textSizeDefaultLabel;

  /// Description of the Default text-size option.
  String get textSizeDefaultDescription;

  /// Text-size option: 115%.
  String get textSizeLargeLabel;

  /// Description of the Large text-size option.
  String get textSizeLargeDescription;

  /// Text-size option: 130%.
  String get textSizeExtraLargeLabel;

  /// Description of the Extra large text-size option.
  String get textSizeExtraLargeDescription;

  // ---- More pane + Activity (P1 batch 6) ----

  /// A
  String get moreSectionWorkspace;

  /// c
  String get moreSectionOrganization;

  /// t
  String get moreSectionAutomation;

  /// i
  String get moreSectionSystem;

  /// v
  String get moreUnassignedChatsTitle;

  /// i
  String get moreUnassignedChatsSubtitle;

  /// t
  String get moreArchivedQuickTitle;

  /// y
  String get moreArchivedQuickSubtitle;

  ///
  String get moreFilesTitle;

  /// f
  String get moreFilesSubtitle;

  /// e
  String get moreAssetsTitle;

  /// e
  String get moreAssetsSubtitle;

  /// d
  String get morePinBatchUndoTitle;

  /// :
  String get morePinBatchUndoSubtitle;

  ///
  String get moreAiFilingTitle;

  /// u
  String get moreAiFilingSubtitle;

  /// n
  String get moreCronTitle;

  /// r
  String get moreCronSubtitle;

  /// e
  String get moreSkillsTitle;

  /// a
  String get moreSkillsSubtitle;

  /// d
  String get moreMemoryTitle;

  /// a
  String get moreMemorySubtitle;

  /// b
  String get moreSettingsTitle;

  /// l
  String get moreSettingsSubtitle;

  /// e
  String get moreDashboardTitle;

  ///
  String get moreDashboardSubtitle;

  /// f
  String get moreDashboardRequired;

  /// e
  String get moreGatewayAssetsRequired;

  /// e
  String get moreGatewayOrganizationRequired;

  /// d
  String get moreGatewayAiFilingRequired;

  ///
  String get activityAndCountMore;

  /// e
  String get activityOfflineBanner;

  /// r
  String get activityReadFailed;

  /// Activity feed: error-state body explaining how the feed is built.
  String get activityReadFailedMessage;

  // ---- Connection editor: proxy & dashboard (P1 batch 6) ----
  /// Custom proxy and dashboard details
  String get connProxySectionTitle;

  /// Used for hosted path prefixes and for the Settings, Memory, Skills and Cron tabs. Leave username/password blank for an open dashboard, or enable proxied mode when your reverse proxy injects dashboard auth.
  String get connProxyIntro;

  /// Gateway path prefix
  String get connGatewayPrefixLabel;

  /// e.g. /profile/peter
  String get connGatewayPrefixHintProfile;

  /// e.g. /profile/peter (proxy path before /api/ and /v1/)
  String get connGatewayPrefixHintProxy;

  /// Dashboard path prefix
  String get connDashboardPrefixLabel;

  /// e.g. /dashboard
  String get connDashboardPrefixHint;

  /// e.g. /dashboard (proxy path before /api/)
  String get connDashboardPrefixHintProxy;

  /// Dashboard behind proxy
  String get connDashboardBehindProxy;

  /// Proxy injects auth; app sends clean requests
  String get connDashboardBehindProxySub;

  /// Nginx injects auth — app sends clean requests
  String get connDashboardBehindProxySubNginx;

  /// Dashboard Port
  String get connDashPortLabel;

  /// Leave blank for default (9119)
  String get connDashPortHint;

  /// Optional. For the Memory/Cron/Skills/Settings tabs. Leave blank to use the default dashboard port (9119) with no login.
  String get connDashPortOptionalNote;

  /// Username (optional)
  String get connUsernameOptional;

  /// Password (optional)
  String get connPasswordOptional;

  /// Dashboard Username (optional)
  String get connDashUsernameOptional;

  /// Dashboard Password (optional)
  String get connDashPasswordOptional;

  /// Desktop Gateway URL (optional)
  String get connDesktopGatewayUrl;

  /// https://hermes-desktop.example.lan
  String get connDesktopGatewayUrlHint;

  /// Enables file attachments through the Desktop remote gateway.
  String get connDesktopGatewayUrlHelper;

  /// Hermes profile (optional)
  String get connHermesProfile;

  /// e.g. sol
  String get connHermesProfileHint;

  /// Profile this connection chats as when the dashboard serves several profiles. Leave blank for an isolated per-profile dashboard.
  String get connHermesProfileHelper;

  /// Dashboard / Proxy Settings
  String get connDashboardProxySettings;

  /// Semantics label of the model / scope button.
  String get chatChooseModel;

  /// Semantics label of the attachment-draft strip.
  String get chatAttachmentDrafts;

  /// Semantics label of the add-attachment button.
  String get chatAddAttachment;

  /// Tooltip of the add-attachment button.
  String get chatAttachImageOrFile;

  // ---- Gateway activity & turn status (P1 batch 7) ----

  /// Running
  String get activityToolPhaseRunning;

  /// Preparing
  String get activityToolPhasePreparing;

  /// Working
  String get activityToolPhaseWorking;

  /// Completed
  String get activityToolPhaseCompleted;

  /// Failed
  String get activityToolPhaseFailed;

  /// Completed in {0}
  String get activityToolCompletedIn;

  /// Failed after {0}
  String get activityToolFailedAfter;

  /// {0} ms
  String get activityDurationMilliseconds;

  /// {0} s
  String get activityDurationSeconds;

  /// Tool
  String get activityToolFallbackName;

  /// Tool activity
  String get activityToolLabel;

  /// Compacting conversation context…
  String get activityTurnCompacting;

  /// Conversation context compacted
  String get activityTurnCompacted;

  /// Using {0}…
  String get activityTurnUsingTool;

  /// {0}: {1}
  String get activityToolRowLabel;

  /// Hermes is using a tool
  String get activityCardUsingOneTool;

  /// Hermes is using {0} tools
  String get activityCardUsingTools;

  /// {0} failed • {1} total
  String get activityCardSomeFailed;

  /// {0} completed
  String get activityCardAllCompleted;

  /// Nothing is running
  String get activityEmptyTitleRunning;

  /// No turn is blocked, in flight, or recently finished. Work you start will show up here.
  String get activityEmptyMessageRunning;

  /// Inbox is clear
  String get activityEmptyTitleActionable;

  /// No turn needs your input or has failed.
  String get activityEmptyMessageActionable;
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

  @override
  String get drawerProfile => 'Profile';

  @override
  String get drawerProfileAction => 'Switch profile';

  @override
  String get drawerSpaces => 'Spaces';

  @override
  String get drawerWorkspace => 'Workspace';

  @override
  String get drawerWorkspaceSubtitle => 'Projects, Activity — new navigation';

  @override
  String get drawerMemory => 'Memory';

  @override
  String get drawerCronJobs => 'Cron Jobs';

  @override
  String get drawerSkills => 'Skills';

  @override
  String get drawerSettings => 'Settings';

  @override
  String get chatsConnecting => 'Connecting to {0}...';

  @override
  String get chatsConnectingHint =>
      'Make sure the Gateway API Server is running\n(hermes gateway status)';

  @override
  String get chatsConnectionIssue => 'Connection issue';

  @override
  String get chatsNoSessions => 'No sessions yet';

  @override
  String get chatsNoSessionsHint => 'Tap the + button to start a new chat';

  @override
  String get chatsRowMeta => '{0} msgs \u2022 {1} \u2022 {2}';

  @override
  String get chatsNewChat => 'New Chat';

  @override
  String get chatsSwitchProfile => 'Switch profile';

  @override
  String get chatsRenameChat => 'Rename chat';

  @override
  String get chatsRename => 'Rename';

  @override
  String get chatsBranchChat => 'Branch chat';

  @override
  String get chatsDelete => 'Delete';

  @override
  String get chatsMoveToSpace => 'Move to space';

  @override
  String get chatsMoveChat => 'Move chat';

  @override
  String get chatsMoveChatChoose => 'Choose its destination space';

  @override
  String get chatsMoveUnassigned => 'Unassigned';

  @override
  String get chatsDeleteSessionTitle => 'Delete session?';

  @override
  String get chatsDeleteSessionBody =>
      'Delete "{0}" from the remote Hermes history? This cannot be undone.';

  @override
  String get chatsSessionDeleted => 'Session deleted from remote Hermes.';

  @override
  String get chatsActions => 'Chat actions';

  @override
  String get chatsUntitledSession => 'Untitled session';

  @override
  String get chatsProfile => 'Profile';

  @override
  String get chatsRenamePrompt => 'Rename chat';

  @override
  String get chatsBranchCreated => 'Branch created in Hermes history.';

  @override
  String get chatsDeleted => 'Session deleted from remote Hermes.';

  @override
  String get chatsDeleteFailed => 'Could not delete session: {0}';

  @override
  String get chatsRenameFailed => 'Could not rename chat: {0}';

  @override
  String get chatsClearSearch => 'Clear search';

  @override
  String get chatsChangeAiSearchModel => 'Change AI search model';

  @override
  String get chatsSearchMode => 'Search mode';

  @override
  String get chatsSearchHintAi => 'Ask AI to find a conversation';

  @override
  String get chatsSearchHintFullText => 'Search all message content';

  @override
  String get chatsSearchHintLoaded => 'Search loaded chats';

  @override
  String get chatsSearchOnDevice => 'On-device';

  @override
  String get chatsSearchOnDeviceDetail => 'Titles, previews, and models';

  @override
  String get chatsSearchFullText => 'Full-text';

  @override
  String get chatsSearchFullTextDetail => 'All stored message content';

  @override
  String get chatsSearchAiFullText => 'AI + full-text';

  @override
  String get chatsSearchUseOnDevice => 'Use on-device';

  @override
  String get chatsSearchNoMatches => 'No message-content matches';

  @override
  String get chatsSearchAiSearchedFor => 'AI searched for: {0}';

  @override
  String get chatsSearchAiFullTextTitle => 'AI + full-text';

  @override
  String get chatsSearchAiChooseModel =>
      'Choose a small model to rewrite queries';

  @override
  String get chatsAiModelTitle => 'AI search model';

  @override
  String get chatsAiModelDescription =>
      'The model only rewrites your question into a short full-text query. '
      'Hermes uses the provider credentials already configured on the host.';

  @override
  String get chatsAiModelLoadFailed => 'Could not load AI search models: {0}';

  @override
  String get chatsProfileHeader => 'Profile';

  @override
  String get chatsBranchChatTitle => 'Branch chat';

  @override
  String get chatsBranchCreate => 'Create branch';

  @override
  String get projectsTitle => 'Projects';

  @override
  String get projectsArchived => 'Archived';

  @override
  String get projectsActive => 'Active';

  @override
  String get projectsActions => 'Project actions';

  @override
  String get projectsRename => 'Rename project';

  @override
  String get projectsArchive => 'Archive project';

  @override
  String get projectsRestore => 'Restore project';

  @override
  String get projectsEmptyTitle => 'No projects yet';

  @override
  String get projectsEmptyMessage =>
      'Projects group related chats, files, and activity, and stay in sync '
      'with Hermes on your computer.';

  @override
  String get projectsCreateAction => 'Create a project';

  @override
  String get projectsNewProject => 'New project';

  @override
  String get projectsNewDialogTitle => 'New project';

  @override
  String get projectsCreate => 'Create';

  @override
  String get projectsNameLabel => 'Name';

  @override
  String get projectsNameRequired => 'Enter a name';

  @override
  String get projectsArchiveConfirmTitle => 'Archive {0}?';

  @override
  String get projectsArchiveConfirmBody =>
      'The Project will move to Archived. Its chats and files stay intact, '
      'and you can restore it at any time.';

  @override
  String get projectsArchiveConfirmAction => 'Archive';

  @override
  String get projectsRenameDialogTitle => 'Rename {0}';

  @override
  String get projectsRenameAction => 'Rename';

  @override
  String get projectsMutationFailed => 'Could not {0} the project: {1}';

  @override
  String get projectsActionCreate => 'create';

  @override
  String get projectsActionRename => 'rename';

  @override
  String get projectsActionArchive => 'archive';

  @override
  String get projectsActionRestore => 'restore';

  @override
  String get projectsUnreachableTitle => 'Could not reach Hermes';

  @override
  String get projectsUnreachableMessage =>
      'Check that the gateway is running and reachable, then try again.';

  @override
  String get projectsOfflineBanner =>
      'Offline — showing the last known projects.';

  @override
  String get projectsLocalSpaceSubtitle => '{0} · on this device only';

  @override
  String get projectsOneChat => '1 chat';

  @override
  String get projectsChatCount => '{0} chats';

  @override
  String get projectsCompatibilityMode => 'Compatibility mode';

  @override
  String get projectsCompatibilityExplanation =>
      'This Hermes gateway is older than server-side projects, so chats stay '
      'grouped on this device only. Update Hermes to share the same projects '
      'across your devices.';

  @override
  String get projectsNoLocalSpacesTitle => 'No spaces on this device';

  @override
  String get projectsNoLocalSpacesMessage =>
      'Chats from this gateway are not grouped yet. Grouping stays on this '
      'phone until the gateway can host projects.';

  @override
  String get projectsOnThisDevice => 'On this device';

  @override
  String get projectsReviewLocalSpaces => 'Review local spaces';

  @override
  String get projectDetailMoveConversation => 'Move conversation';

  @override
  String get projectDetailUnassigned => 'Unassigned';

  @override
  String get projectDetailMovedTo => 'Moved to {0}';

  @override
  String get projectDetailMoveFailed => 'Couldn’t move conversation';

  @override
  String get commonRetryShort => 'Retry';

  @override
  String get projectDetailRenameTitle => 'Rename {0}';

  @override
  String get projectDetailRename => 'Rename';

  @override
  String get projectDetailArchiveConfirmTitle => 'Archive {0}?';

  @override
  String get projectDetailArchiveConfirmBody =>
      'The Project will move to Archived. Its chats and files stay intact, '
      'and you can restore it later.';

  @override
  String get projectDetailArchive => 'Archive';

  @override
  String get projectDetailDeleteConfirmTitle => 'Delete {0}?';

  @override
  String get projectDetailDeleteConfirmBody =>
      'This permanently deletes the Project. Chats will not be deleted; '
      'they’ll return to Unassigned.';

  @override
  String get projectDetailDelete => 'Delete';

  @override
  String get projectDetailManageFailed => 'Couldn’t {0} project';

  @override
  String get projectDetailDeleteFailed => 'Couldn’t delete project';

  @override
  String get projectDetailNewChat => 'New chat';

  @override
  String get projectDetailChats => 'Chats';

  @override
  String get projectDetailConversations => 'Conversations in this project';

  @override
  String get projectDetailRepositories => 'Repositories';

  @override
  String get projectDetailLocation => 'Location';

  @override
  String get projectDetailFolders => 'Folders';

  @override
  String get projectDetailNoFoldersTitle => 'No folders yet';

  @override
  String get projectDetailNoFoldersMessage =>
      'The server has not reported folders for this project yet. Global Files '
      'stays available from More.';

  @override
  String get projectDetailAssetsUnavailableTitle => 'Assets unavailable';

  @override
  String get projectDetailAssetsUnavailableMessage =>
      'Assets need a server-authoritative Assets index in the Hermes Gateway '
      'before they can be shown per project.';

  @override
  String get projectDetailNoActivityTitle => 'No activity yet';

  @override
  String get projectDetailNoActivityMessage =>
      'Chats in this project will show their state and last activity here.';

  @override
  String get projectDetailSearchChats => 'Search chats';

  @override
  String get projectDetailClearSearch => 'Clear search';

  @override
  String get projectDetailNoChatsTitle => 'No chats yet';

  @override
  String get projectDetailNoChatsMessage =>
      'Chats you start in this project will appear here, on every device '
      'signed in to this Hermes.';

  @override
  String get projectDetailNoMatchesTitle => 'No matches';

  @override
  String get projectDetailNoMatchesMessage =>
      'No chats in this project match “{0}”.';

  @override
  String get projectDetailUnsupportedTitle => 'Project chats unavailable';

  @override
  String get projectDetailUnsupportedMessage =>
      'This Hermes gateway does not support opening a project yet. Update '
      'Hermes on the server to browse a project from your phone.';

  @override
  String get projectDetailOpenFailedTitle => 'Could not open this project';

  @override
  String get projectDetailOpenFailedMessage =>
      'Check that the gateway is running and reachable, then try again.';

  @override
  String get projectDetailOfflineBanner =>
      'Offline — showing the last known chats';

  @override
  String get projectDetailTabOverview => 'Overview';

  @override
  String get projectDetailTabFiles => 'Files';

  @override
  String get projectDetailTabAssets => 'Assets';

  @override
  String get projectDetailTabActivity => 'Activity';

  @override
  String get projectDetailDeleteProject => 'Delete project';

  @override
  String get filesTitle => 'Files';

  @override
  String get filesEmptyTitle => 'Folder is empty';

  @override
  String get filesEmptyMessage =>
      'There are no visible files in this server folder.';

  @override
  String get filesPreviewTruncated => 'Preview truncated';

  @override
  String get filesPreviewUnavailable => 'Preview unavailable';

  @override
  String get filesBinaryPreviewUnavailable =>
      'Binary preview is unavailable. Download the file to open it.';

  @override
  String get filesDownload => 'Download';

  @override
  String get filesDownloaded => '{0} downloaded';

  @override
  String get filesDownloadFailed => 'Download failed: {0}';

  @override
  String get filesAddedToChat => 'File reference added to chat';

  @override
  String get filesAddToChat => 'Add to chat';

  @override
  String get filesLoadFailedTitle => 'Could not load files';

  @override
  String get filesPreviewFailedTitle => 'Could not preview file';

  @override
  String get filesErrorMessage =>
      'Check the Dashboard connection and try again.';

  @override
  String get filesSaveDialogTitle => 'Save {0}';

  @override
  String get skillsTitle => 'Skills ({0})';

  @override
  String get skillsLoadFailed => 'Failed to load skills';

  @override
  String get skillsEmptyTitle => 'No skills found';

  @override
  String get skillsEmptyMessage =>
      'Skills are reusable agent instructions published by the Hermes host.';

  @override
  String get memoryTitle => 'Memory';

  @override
  String get memorySource => 'Source: {0}';

  @override
  String get memoryLoadFailed => 'Failed to load memory';

  @override
  String get memoryEmptyTitle => 'No memory entries';

  @override
  String get memoryEmptyMessage =>
      'Memory entries are cross-session facts the agent remembers.\n'
      'They are stored on the Hermes host and shared across your devices.';

  @override
  String get cronTitle => 'Cron Jobs';

  @override
  String get cronAddJob => 'Add Cron Job';

  @override
  String get cronEditJob => 'Edit Cron Job';

  @override
  String get cronNameLabel => 'Name';

  @override
  String get cronNameHint => 'e.g., Daily backup';

  @override
  String get cronPromptLabel => 'Prompt';

  @override
  String get cronPromptHint => 'What should the agent do?';

  @override
  String get cronScheduleLabel => 'Schedule';

  @override
  String get cronScheduleHint => 'e.g., 0 9 * * * or every 2h';

  @override
  String get cronAddNewJob => 'Add new cron job';

  @override
  String get cronScriptOnly => 'Script only (no agent)';

  @override
  String get cronScriptOnlyHint => 'Use for cron jobs backed by scripts.';

  @override
  String get cronFieldsRequired => 'Name, prompt, and schedule are required';

  @override
  String get cronJobAdded => 'Cron job added';

  @override
  String get cronJobUpdated => 'Cron job updated';

  @override
  String get cronJobDeleted => 'Deleted “{0}”';

  @override
  String get cronJobTriggered => 'Job triggered';

  @override
  String get cronJobResumed => 'Job resumed';

  @override
  String get cronJobPaused => 'Job paused';

  @override
  String get cronTriggerNow => 'Trigger now';

  @override
  String get cronEdit => 'Edit';

  @override
  String get cronDelete => 'Delete';

  @override
  String get cronDeleteConfirmTitle => 'Delete “{0}”?';

  @override
  String get cronNeverRun => 'Never';

  @override
  String get cronLastRun => 'Last: {0}';

  @override
  String get cronNextRun => 'Next: {0}';

  @override
  String get cronOperationFailed => 'Failed: {0}';

  @override
  String get cronLoadFailed => 'Failed to load cron jobs';

  @override
  String get cronPause => 'Pause';

  @override
  String get cronResume => 'Resume';

  @override
  String get cronAddAction => 'Add';

  @override
  String get cronSaveAction => 'Save';

  @override
  String get cronScriptBadge => 'script';

  @override
  String get cronDeleteConfirmBody => 'Delete “{0}”?';

  @override
  String get cronEmptyTitle => 'No cron jobs';

  @override
  String get cronEmptyMessage =>
      'Scheduled jobs run agent turns on the Hermes host on your behalf.';

  @override
  String get spacesTitle => 'Spaces';

  @override
  String get spacesNewSpace => 'New space';

  @override
  String get spacesAllChats => 'All chats';

  @override
  String get spacesUnassigned => 'Unassigned';

  @override
  String get spacesActions => 'Space actions';

  @override
  String get spacesRename => 'Rename';

  @override
  String get spacesEmptyHint =>
      'Create a space to separate related conversations.';

  @override
  String get spacesNewDialogTitle => 'New space';

  @override
  String get spacesRenameDialogTitle => 'Rename space';

  @override
  String get spacesNameLabel => 'Name';

  @override
  String get spacesNameRequired => 'Enter a name';

  @override
  String get spacesLastActivity => 'Last activity {0}';

  @override
  String get workspaceChatsTitle => 'Chats';

  @override
  String get workspaceProjectsUnavailableTitle => 'Projects unavailable';

  @override
  String get workspaceProjectsUnavailableMessage =>
      'Projects need a Desktop Gateway connection. Add the Desktop Gateway URL '
      'to this connection to organize chats across your devices.';

  @override
  String get workspaceInbox => 'Inbox';

  @override
  String get workspaceNewChat => 'New';

  @override
  String get workspaceSearchAllChats => 'Search all chats';

  @override
  String get workspaceDashboardOpenFailed =>
      'Could not open the Hermes dashboard.';

  @override
  String get workspaceProjectChatFailed => 'Couldn’t create Project chat';

  @override
  String get workspaceRetry => 'Retry';

  @override
  String get workspaceProjectFolderFallback =>
      'This gateway can\u2019t file chats into projects directly — opened in '
      'the project\u2019s folder instead.';

  @override
  String get workspaceSharedFilesFailed => 'Couldn’t prepare the shared files.';

  @override
  String get workspaceSessionsLoadFailedTitle => 'Could not load conversations';

  @override
  String get workspaceSessionsLoadFailedMessage =>
      'Check the connection and try again.';

  @override
  String get workspaceSessionsSearchHint => 'Search conversations';

  @override
  String get workspaceSessionsSearchClear => 'Clear search';

  @override
  String get workspaceSessionsUnassigned => 'Unassigned';

  @override
  String get workspaceSessionsPromoteTooltip => 'Promote to project';

  @override
  String get workspaceSessionsPromoted => 'Promoted to a Project';

  @override
  String get workspaceSessionsPromoteFailed => 'Couldn’t promote conversation';

  @override
  String get chatReadingAloud => 'Reading response aloud';

  @override
  String get chatReadAloudUnavailable =>
      'Read aloud is unavailable on this device';

  @override
  String get chatTakePhoto => 'Take photo';

  @override
  String get chatBrowseServerFiles => 'Browse server files';

  @override
  String get chatInsertRemoteReference => 'Insert a remote @file reference';

  @override
  String get chatChooseFiles => 'Choose files';

  @override
  String get chatLocalFileTypes => 'Documents, archives, audio, video, or data';

  @override
  String get chatIntakePending =>
      'File attached; document catalog registration is pending.';

  @override
  String get chatModelAndThinking => 'Model and thinking for this chat';

  @override
  String get chatProfileDefault => 'Profile default: {0}';

  @override
  String get chatCancel => 'Cancel';

  @override
  String get chatApplyToThisChat => 'Apply to this chat';

  @override
  String get chatModelLoadFailed =>
      'Could not load models for this profile: {0}';

  @override
  String get chatOverrideApplied => '{0} • {1} now apply only to this chat.';

  @override
  String get chatModelChangeFailed => 'Model was not changed: {0}';

  @override
  String get chatDenyFailed => 'Could not deny the command: {0}';

  @override
  String get chatSkipQuestionFailed => 'Could not skip the Hermes question.';

  @override
  String get chatStopFailed =>
      'Response closed locally; gateway stop failed: {0}';

  @override
  String get chatSendFailed => 'Send failed: {0}';

  @override
  String get chatResponding => 'Responding…';

  @override
  String get chatActions => 'Chat actions';

  @override
  String get chatRefresh => 'Refresh';

  @override
  String get chatExportShare => 'Export / share';

  @override
  String get chatDismiss => 'Dismiss';

  @override
  String get chatModelButton => '{0} • {1}';

  @override
  String get chatThisChatScope => 'this chat';

  @override
  String get chatProfileDefaultScope => 'profile default';

  @override
  String get chatMessageField => 'Message';

  @override
  String get chatMessageHint => 'Message Hermes…';

  @override
  String get chatSpokenReplies => 'Spoken replies';

  @override
  String get chatStopResponse => 'Stop response';

  @override
  String get chatSend => 'Send';

  @override
  String get chatLoadFailedTitle => 'Failed to load messages';

  @override
  String get chatMessageActions => 'Message actions';

  @override
  String get chatMessageCopied => 'Message copied';

  @override
  String get chatCopyMessage => 'Copy message';

  @override
  String get chatReadAloud => 'Read aloud';

  @override
  String get chatEditAndResend => 'Edit and resend';

  @override
  String get chatRegenerate => 'Regenerate response';

  @override
  String get chatThinkingEffort => 'Thinking effort';

  @override
  String get chatChooseModel => 'Choose chat model';

  @override
  String get chatAttachmentDrafts => 'Attachment drafts';

  @override
  String get chatAddAttachment => 'Add attachment';

  @override
  String get chatAttachImageOrFile => 'Attach image or file';

  @override
  String get textSizeSystemLabel => 'System';

  @override
  String get textSizeSystemDescription =>
      'Use Android accessibility text size exactly.';

  @override
  String get textSizeSmallLabel => 'Small';

  @override
  String get textSizeSmallDescription => '90% of the Android text size.';

  @override
  String get textSizeDefaultLabel => 'Default';

  @override
  String get textSizeDefaultDescription => '100% of the Android text size.';

  @override
  String get textSizeLargeLabel => 'Large';

  @override
  String get textSizeLargeDescription => '115% of the Android text size.';

  @override
  String get textSizeExtraLargeLabel => 'Extra large';

  @override
  String get textSizeExtraLargeDescription => '130% of the Android text size.';

  @override
  String get moreSectionWorkspace => 'Workspace';
  @override
  String get moreSectionOrganization => 'Organization';
  @override
  String get moreSectionAutomation => 'Automation';
  @override
  String get moreSectionSystem => 'System';
  @override
  String get moreUnassignedChatsTitle => 'Unassigned chats';
  @override
  String get moreUnassignedChatsSubtitle =>
      'Chats that are not assigned to a Project';
  @override
  String get moreArchivedQuickTitle => 'Archived quick chats';
  @override
  String get moreArchivedQuickSubtitle =>
      'Review or promote quick chats past their retention period';
  @override
  String get moreFilesTitle => 'Files';
  @override
  String get moreFilesSubtitle =>
      'Browse the miniserver folders behind your projects';
  @override
  String get moreAssetsTitle => 'Assets';
  @override
  String get moreAssetsSubtitle =>
      'Artifacts, attachments, and generated media';
  @override
  String get morePinBatchUndoTitle => 'Pin, batch and undo';
  @override
  String get morePinBatchUndoSubtitle =>
      'Cross-device ordering and reversible bulk organization';
  @override
  String get moreAiFilingTitle => 'AI-assisted filing';
  @override
  String get moreAiFilingSubtitle =>
      'Suggest Projects and learn from your corrections';
  @override
  String get moreCronTitle => 'Cron';
  @override
  String get moreCronSubtitle => 'Scheduled jobs and their last runs';
  @override
  String get moreSkillsTitle => 'Skills and tools';
  @override
  String get moreSkillsSubtitle => 'What Hermes knows how to do';
  @override
  String get moreMemoryTitle => 'Memory';
  @override
  String get moreMemorySubtitle => 'Durable facts Hermes keeps about you';
  @override
  String get moreSettingsTitle => 'Settings';
  @override
  String get moreSettingsSubtitle =>
      'Connection, appearance, and device preferences';
  @override
  String get moreDashboardTitle => 'Open the Hermes dashboard';
  @override
  String get moreDashboardSubtitle =>
      'Everything not yet native, in the authenticated web dashboard';
  @override
  String get moreDashboardRequired =>
      'Needs a reachable Hermes dashboard. Check the host, port, and credentials of this connection.';
  @override
  String get moreGatewayAssetsRequired =>
      'Needs a server-authoritative Assets index in the Hermes Gateway.';
  @override
  String get moreGatewayOrganizationRequired =>
      'Needs durable pin ordering, batch mutation, and undo contracts in the Hermes Gateway.';
  @override
  String get moreGatewayAiFilingRequired =>
      'Needs a correction-aware filing contract in the Hermes Gateway.';
  @override
  String get activityAndCountMore => 'and {0} more';
  @override
  String get activityOfflineBanner =>
      'Offline — showing the last known activity.';
  @override
  String get activityReadFailed => 'Could not read activity';

  @override
  String get activityReadFailedMessage =>
      'Activity reads the durable turn journal to know what Hermes is doing. '
      'Check that the gateway is reachable, then try again.';

  @override
  String get connProxySectionTitle => 'Custom proxy and dashboard details';

  @override
  String get connProxyIntro =>
      'Used for hosted path prefixes and for the Settings, Memory, Skills and Cron tabs. Leave username/password blank for an open dashboard, or enable proxied mode when your reverse proxy injects dashboard auth.';

  @override
  String get connGatewayPrefixLabel => 'Gateway path prefix';

  @override
  String get connGatewayPrefixHintProfile => 'e.g. /profile/peter';

  @override
  String get connGatewayPrefixHintProxy =>
      'e.g. /profile/peter (proxy path before /api/ and /v1/)';

  @override
  String get connDashboardPrefixLabel => 'Dashboard path prefix';

  @override
  String get connDashboardPrefixHint => 'e.g. /dashboard';

  @override
  String get connDashboardPrefixHintProxy =>
      'e.g. /dashboard (proxy path before /api/)';

  @override
  String get connDashboardBehindProxy => 'Dashboard behind proxy';

  @override
  String get connDashboardBehindProxySub =>
      'Proxy injects auth; app sends clean requests';

  @override
  String get connDashboardBehindProxySubNginx =>
      'Nginx injects auth — app sends clean requests';

  @override
  String get connDashPortLabel => 'Dashboard Port';

  @override
  String get connDashPortHint => 'Leave blank for default (9119)';

  @override
  String get connDashPortOptionalNote =>
      'Optional. For the Memory/Cron/Skills/Settings tabs. Leave blank to use the default dashboard port (9119) with no login.';

  @override
  String get connUsernameOptional => 'Username (optional)';

  @override
  String get connPasswordOptional => 'Password (optional)';

  @override
  String get connDashUsernameOptional => 'Dashboard Username (optional)';

  @override
  String get connDashPasswordOptional => 'Dashboard Password (optional)';

  @override
  String get connDesktopGatewayUrl => 'Desktop Gateway URL (optional)';

  @override
  String get connDesktopGatewayUrlHint => 'https://hermes-desktop.example.lan';

  @override
  String get connDesktopGatewayUrlHelper =>
      'Enables file attachments through the Desktop remote gateway.';

  @override
  String get connHermesProfile => 'Hermes profile (optional)';

  @override
  String get connHermesProfileHint => 'e.g. sol';

  @override
  String get connHermesProfileHelper =>
      'Profile this connection chats as when the dashboard serves several profiles. Leave blank for an isolated per-profile dashboard.';

  @override
  String get connDashboardProxySettings => 'Dashboard / Proxy Settings';

  // ---- Gateway activity & turn status (P1 batch 7) ----

  @override
  String get activityToolPhaseRunning => 'Running';

  @override
  String get activityToolPhasePreparing => 'Preparing';

  @override
  String get activityToolPhaseWorking => 'Working';

  @override
  String get activityToolPhaseCompleted => 'Completed';

  @override
  String get activityToolPhaseFailed => 'Failed';

  @override
  String get activityToolCompletedIn => 'Completed in {0}';

  @override
  String get activityToolFailedAfter => 'Failed after {0}';

  @override
  String get activityDurationMilliseconds => '{0} ms';

  @override
  String get activityDurationSeconds => '{0} s';

  @override
  String get activityToolFallbackName => 'Tool';

  @override
  String get activityToolLabel => 'Tool activity';

  @override
  String get activityTurnCompacting => 'Compacting conversation context…';

  @override
  String get activityTurnCompacted => 'Conversation context compacted';

  @override
  String get activityTurnUsingTool => 'Using {0}…';

  @override
  String get activityToolRowLabel => '{0}: {1}';

  @override
  String get activityCardUsingOneTool => 'Hermes is using a tool';

  @override
  String get activityCardUsingTools => 'Hermes is using {0} tools';

  @override
  String get activityCardSomeFailed => '{0} failed • {1} total';

  @override
  String get activityCardAllCompleted => '{0} completed';

  @override
  String get activityEmptyTitleRunning => 'Nothing is running';

  @override
  String get activityEmptyMessageRunning =>
      'No turn is blocked, in flight, or recently finished. Work you start will show up here.';

  @override
  String get activityEmptyTitleActionable => 'Inbox is clear';

  @override
  String get activityEmptyMessageActionable =>
      'No turn needs your input or has failed.';
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
  String get homeNoConnectionsHint =>
      '点按 + 添加远程 Hermes 网关\n（API Server，端口 8642）';

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
  String get backupDescription => '把连接和设置保存到加密文件，重装或换设备后再恢复。';

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

  @override
  String get drawerProfile => '个人资料';

  @override
  String get drawerProfileAction => '切换个人资料';

  @override
  String get drawerSpaces => '空间';

  @override
  String get drawerWorkspace => '工作区';

  @override
  String get drawerWorkspaceSubtitle => '项目、动态 — 全新导航';

  @override
  String get drawerMemory => '记忆';

  @override
  String get drawerCronJobs => '定时任务';

  @override
  String get drawerSkills => '技能';

  @override
  String get drawerSettings => '设置';

  @override
  String get chatsConnecting => '正在连接 {0}...';

  @override
  String get chatsConnectingHint =>
      '请确认 Gateway API Server 正在运行\n(hermes gateway status)';

  @override
  String get chatsConnectionIssue => '连接问题';

  @override
  String get chatsNoSessions => '暂无会话';

  @override
  String get chatsNoSessionsHint => '点按 + 按钮开始新会话';

  @override
  String get chatsRowMeta => '{0} 条消息 \u2022 {1} \u2022 {2}';

  @override
  String get chatsNewChat => '新会话';

  @override
  String get chatsSwitchProfile => '切换个人资料';

  @override
  String get chatsRenameChat => '重命名会话';

  @override
  String get chatsRename => '重命名';

  @override
  String get chatsBranchChat => '分叉会话';

  @override
  String get chatsDelete => '删除';

  @override
  String get chatsMoveToSpace => '移动到空间';

  @override
  String get chatsMoveChat => '移动会话';

  @override
  String get chatsMoveChatChoose => '选择目标空间';

  @override
  String get chatsMoveUnassigned => '未分配';

  @override
  String get chatsDeleteSessionTitle => '删除会话？';

  @override
  String get chatsDeleteSessionBody => '要从远端 Hermes 历史中删除“{0}”吗？此操作无法撤销。';

  @override
  String get chatsSessionDeleted => '已从远端 Hermes 历史中删除会话。';

  @override
  String get chatsActions => '会话操作';

  @override
  String get chatsUntitledSession => '未命名会话';

  @override
  String get chatsProfile => '个人资料';

  @override
  String get chatsRenamePrompt => '重命名会话';

  @override
  String get chatsBranchCreated => '已在 Hermes 历史中创建分叉。';

  @override
  String get chatsDeleted => '已从远端 Hermes 历史中删除会话。';

  @override
  String get chatsDeleteFailed => '删除会话失败：{0}';

  @override
  String get chatsRenameFailed => '重命名会话失败：{0}';

  @override
  String get chatsClearSearch => '清除搜索';

  @override
  String get chatsChangeAiSearchModel => '更改 AI 搜索模型';

  @override
  String get chatsSearchMode => '搜索模式';

  @override
  String get chatsSearchHintAi => '让 AI 查找会话';

  @override
  String get chatsSearchHintFullText => '搜索全部消息内容';

  @override
  String get chatsSearchHintLoaded => '搜索已加载的会话';

  @override
  String get chatsSearchOnDevice => '设备端';

  @override
  String get chatsSearchOnDeviceDetail => '标题、预览和模型';

  @override
  String get chatsSearchFullText => '全文';

  @override
  String get chatsSearchFullTextDetail => '全部已存储的消息内容';

  @override
  String get chatsSearchAiFullText => 'AI + 全文';

  @override
  String get chatsSearchUseOnDevice => '使用设备端搜索';

  @override
  String get chatsSearchNoMatches => '没有匹配的消息内容';

  @override
  String get chatsSearchAiSearchedFor => 'AI 实际搜索：{0}';

  @override
  String get chatsSearchAiFullTextTitle => 'AI + 全文';

  @override
  String get chatsSearchAiChooseModel => '选择一个小模型来改写查询';

  @override
  String get chatsAiModelTitle => 'AI 搜索模型';

  @override
  String get chatsAiModelDescription =>
      '该模型只把你的问题改写成简短的全文查询。Hermes 使用主机上已配置的服务提供商凭据。';

  @override
  String get chatsAiModelLoadFailed => '加载 AI 搜索模型失败：{0}';

  @override
  String get chatsProfileHeader => '个人资料';

  @override
  String get chatsBranchChatTitle => '分叉会话';

  @override
  String get chatsBranchCreate => '创建分叉';

  @override
  String get projectsTitle => '项目';

  @override
  String get projectsArchived => '已归档';

  @override
  String get projectsActive => '当前';

  @override
  String get projectsActions => '项目操作';

  @override
  String get projectsRename => '重命名项目';

  @override
  String get projectsArchive => '归档项目';

  @override
  String get projectsRestore => '恢复项目';

  @override
  String get projectsEmptyTitle => '还没有项目';

  @override
  String get projectsEmptyMessage => '项目把相关的会话、文件和动态归到一起，并与电脑上的 Hermes 保持同步。';

  @override
  String get projectsCreateAction => '创建项目';

  @override
  String get projectsNewProject => '新建项目';

  @override
  String get projectsNewDialogTitle => '新建项目';

  @override
  String get projectsCreate => '创建';

  @override
  String get projectsNameLabel => '名称';

  @override
  String get projectsNameRequired => '请输入名称';

  @override
  String get projectsArchiveConfirmTitle => '归档「{0}」？';

  @override
  String get projectsArchiveConfirmBody => '项目将移入「已归档」，其中的会话和文件都会保留，之后可随时恢复。';

  @override
  String get projectsArchiveConfirmAction => '归档';

  @override
  String get projectsRenameDialogTitle => '重命名「{0}」';

  @override
  String get projectsRenameAction => '重命名';

  @override
  String get projectsMutationFailed => '无法{0}项目：{1}';

  @override
  String get projectsActionCreate => '创建';

  @override
  String get projectsActionRename => '重命名';

  @override
  String get projectsActionArchive => '归档';

  @override
  String get projectsActionRestore => '恢复';

  @override
  String get projectsUnreachableTitle => '无法连接到 Hermes';

  @override
  String get projectsUnreachableMessage => '请确认网关正在运行且可以访问，然后重试。';

  @override
  String get projectsOfflineBanner => '离线 — 显示的是上次已知的项目列表。';

  @override
  String get projectsLocalSpaceSubtitle => '{0} · 仅本机';

  @override
  String get projectsOneChat => '1 个会话';

  @override
  String get projectsChatCount => '{0} 个会话';

  @override
  String get projectsCompatibilityMode => '兼容模式';

  @override
  String get projectsCompatibilityExplanation =>
      '此版本的 Hermes 网关早于服务端项目功能，因此会话分组只保留在本机。更新 Hermes 后即可在多台设备间共享同一批项目。';

  @override
  String get projectsNoLocalSpacesTitle => '本机没有空间';

  @override
  String get projectsNoLocalSpacesMessage =>
      '来自此网关的会话尚未分组。在网关支持托管项目之前，分组只保留在本机上。';

  @override
  String get projectsOnThisDevice => '本机';

  @override
  String get projectsReviewLocalSpaces => '查看本机空间';

  @override
  String get projectDetailMoveConversation => '移动会话';

  @override
  String get projectDetailUnassigned => '未分配';

  @override
  String get projectDetailMovedTo => '已移动到「{0}」';

  @override
  String get projectDetailMoveFailed => '无法移动会话';

  @override
  String get commonRetryShort => '重试';

  @override
  String get projectDetailRenameTitle => '重命名「{0}」';

  @override
  String get projectDetailRename => '重命名';

  @override
  String get projectDetailArchiveConfirmTitle => '归档「{0}」？';

  @override
  String get projectDetailArchiveConfirmBody =>
      '项目将移入「已归档」，其中的会话和文件都会保留，之后可随时恢复。';

  @override
  String get projectDetailArchive => '归档';

  @override
  String get projectDetailDeleteConfirmTitle => '删除「{0}」？';

  @override
  String get projectDetailDeleteConfirmBody => '这将永久删除该项目。会话不会被删除，它们会回到「未分配」。';

  @override
  String get projectDetailDelete => '删除';

  @override
  String get projectDetailManageFailed => '无法{0}项目';

  @override
  String get projectDetailDeleteFailed => '无法删除项目';

  @override
  String get projectDetailNewChat => '新会话';

  @override
  String get projectDetailChats => '会话';

  @override
  String get projectDetailConversations => '此项目中的会话';

  @override
  String get projectDetailRepositories => '仓库';

  @override
  String get projectDetailLocation => '位置';

  @override
  String get projectDetailFolders => '文件夹';

  @override
  String get projectDetailNoFoldersTitle => '还没有文件夹';

  @override
  String get projectDetailNoFoldersMessage => '服务器尚未报告此项目的文件夹。全局「文件」仍可从「更多」进入。';

  @override
  String get projectDetailAssetsUnavailableTitle => '资源不可用';

  @override
  String get projectDetailAssetsUnavailableMessage =>
      '在按项目展示资源之前，需要在 Hermes 网关中建立由服务器维护的资源索引。';

  @override
  String get projectDetailNoActivityTitle => '还没有动态';

  @override
  String get projectDetailNoActivityMessage => '此项目中的会话会在这里显示状态和最近活动时间。';

  @override
  String get projectDetailSearchChats => '搜索会话';

  @override
  String get projectDetailClearSearch => '清除搜索';

  @override
  String get projectDetailNoChatsTitle => '还没有会话';

  @override
  String get projectDetailNoChatsMessage =>
      '你在此项目中开启的会话会显示在这里，登录同一 Hermes 的每台设备都能看到。';

  @override
  String get projectDetailNoMatchesTitle => '没有匹配项';

  @override
  String get projectDetailNoMatchesMessage => '此项目中没有与「{0}」匹配的会话。';

  @override
  String get projectDetailUnsupportedTitle => '项目会话不可用';

  @override
  String get projectDetailUnsupportedMessage =>
      '此版本的 Hermes 网关还不支持打开项目。请在服务器上更新 Hermes，以便从手机浏览项目。';

  @override
  String get projectDetailOpenFailedTitle => '无法打开此项目';

  @override
  String get projectDetailOpenFailedMessage => '请确认网关正在运行且可以访问，然后重试。';

  @override
  String get projectDetailOfflineBanner => '离线 — 显示的是上次已知的会话列表。';

  @override
  String get projectDetailTabOverview => '概览';

  @override
  String get projectDetailTabFiles => '文件';

  @override
  String get projectDetailTabAssets => '资源';

  @override
  String get projectDetailTabActivity => '动态';

  @override
  String get projectDetailDeleteProject => '删除项目';

  @override
  String get filesTitle => '文件';

  @override
  String get filesEmptyTitle => '文件夹为空';

  @override
  String get filesEmptyMessage => '此服务器文件夹中没有可见文件。';

  @override
  String get filesPreviewTruncated => '预览已截断';

  @override
  String get filesPreviewUnavailable => '无法预览';

  @override
  String get filesBinaryPreviewUnavailable => '无法预览二进制文件。请下载后打开。';

  @override
  String get filesDownload => '下载';

  @override
  String get filesDownloaded => '「{0}」已下载';

  @override
  String get filesDownloadFailed => '下载失败：{0}';

  @override
  String get filesAddedToChat => '已把文件引用添加到会话';

  @override
  String get filesAddToChat => '添加到会话';

  @override
  String get filesLoadFailedTitle => '无法加载文件';

  @override
  String get filesPreviewFailedTitle => '无法预览文件';

  @override
  String get filesErrorMessage => '请检查 Dashboard 连接，然后重试。';

  @override
  String get filesSaveDialogTitle => '保存 {0}';

  @override
  String get skillsTitle => '技能（{0}）';

  @override
  String get skillsLoadFailed => '加载技能失败';

  @override
  String get skillsEmptyTitle => '没有找到技能';

  @override
  String get skillsEmptyMessage => '技能是由 Hermes 主机发布的、可复用的智能体指令。';

  @override
  String get memoryTitle => '记忆';

  @override
  String get memorySource => '来源：{0}';

  @override
  String get memoryLoadFailed => '加载记忆失败';

  @override
  String get memoryEmptyTitle => '没有记忆条目';

  @override
  String get memoryEmptyMessage =>
      '记忆条目是智能体跨会话记住的事实。\n它们存储在 Hermes 主机上，并在你的各设备间共享。';

  @override
  String get cronTitle => '定时任务';

  @override
  String get cronAddJob => '添加定时任务';

  @override
  String get cronEditJob => '编辑定时任务';

  @override
  String get cronNameLabel => '名称';

  @override
  String get cronNameHint => '例如：每日备份';

  @override
  String get cronPromptLabel => '提示词';

  @override
  String get cronPromptHint => '希望智能体做什么？';

  @override
  String get cronScheduleLabel => '计划';

  @override
  String get cronScheduleHint => '例如：0 9 * * * 或 every 2h';

  @override
  String get cronAddNewJob => '添加定时任务';

  @override
  String get cronScriptOnly => '仅脚本（不调用智能体）';

  @override
  String get cronScriptOnlyHint => '用于由脚本驱动的定时任务。';

  @override
  String get cronFieldsRequired => '名称、提示词和计划均为必填';

  @override
  String get cronJobAdded => '定时任务已添加';

  @override
  String get cronJobUpdated => '定时任务已更新';

  @override
  String get cronJobDeleted => '已删除「{0}」';

  @override
  String get cronJobTriggered => '任务已触发';

  @override
  String get cronJobResumed => '任务已恢复';

  @override
  String get cronJobPaused => '任务已暂停';

  @override
  String get cronTriggerNow => '立即触发';

  @override
  String get cronEdit => '编辑';

  @override
  String get cronDelete => '删除';

  @override
  String get cronDeleteConfirmTitle => '删除「{0}」？';

  @override
  String get cronNeverRun => '从未';

  @override
  String get cronLastRun => '上次：{0}';

  @override
  String get cronNextRun => '下次：{0}';

  @override
  String get cronOperationFailed => '失败：{0}';

  @override
  String get cronLoadFailed => '加载定时任务失败';

  @override
  String get cronPause => '暂停';

  @override
  String get cronResume => '恢复';

  @override
  String get cronAddAction => '添加';

  @override
  String get cronSaveAction => '保存';

  @override
  String get cronScriptBadge => '脚本';

  @override
  String get cronDeleteConfirmBody => '删除「{0}」？';

  @override
  String get cronEmptyTitle => '没有定时任务';

  @override
  String get cronEmptyMessage => '定时任务会在你指定的时间于 Hermes 主机上运行智能体回合。';

  @override
  String get spacesTitle => '空间';

  @override
  String get spacesNewSpace => '新建空间';

  @override
  String get spacesAllChats => '全部会话';

  @override
  String get spacesUnassigned => '未分配';

  @override
  String get spacesActions => '空间操作';

  @override
  String get spacesRename => '重命名';

  @override
  String get spacesEmptyHint => '创建空间来区分相关的会话。';

  @override
  String get spacesNewDialogTitle => '新建空间';

  @override
  String get spacesRenameDialogTitle => '重命名空间';

  @override
  String get spacesNameLabel => '名称';

  @override
  String get spacesNameRequired => '请输入名称';

  @override
  String get spacesLastActivity => '最近活动 {0}';

  @override
  String get workspaceChatsTitle => '会话';

  @override
  String get workspaceProjectsUnavailableTitle => '项目不可用';

  @override
  String get workspaceProjectsUnavailableMessage =>
      '项目功能需要 Desktop Gateway 连接。请为此连接添加 Desktop Gateway 地址，以便在多台设备间组织会话。';

  @override
  String get workspaceInbox => '收件箱';

  @override
  String get workspaceNewChat => '新建';

  @override
  String get workspaceSearchAllChats => '搜索全部会话';

  @override
  String get workspaceDashboardOpenFailed => '无法打开 Hermes 仪表盘。';

  @override
  String get workspaceProjectChatFailed => '无法创建项目会话';

  @override
  String get workspaceRetry => '重试';

  @override
  String get workspaceProjectFolderFallback => '此网关无法直接把会话归入项目 —— 已在项目的文件夹中打开。';

  @override
  String get workspaceSharedFilesFailed => '无法准备共享文件。';

  @override
  String get workspaceSessionsLoadFailedTitle => '无法加载会话';

  @override
  String get workspaceSessionsLoadFailedMessage => '请检查连接后重试。';

  @override
  String get workspaceSessionsSearchHint => '搜索会话';

  @override
  String get workspaceSessionsSearchClear => '清除搜索';

  @override
  String get workspaceSessionsUnassigned => '未分配';

  @override
  String get workspaceSessionsPromoteTooltip => '升级为项目';

  @override
  String get workspaceSessionsPromoted => '已升级为项目';

  @override
  String get workspaceSessionsPromoteFailed => '无法升级会话';

  @override
  String get chatReadingAloud => '正在朗读回复';

  @override
  String get chatReadAloudUnavailable => '此设备不支持朗读功能';

  @override
  String get chatTakePhoto => '拍摄照片';

  @override
  String get chatBrowseServerFiles => '浏览服务器文件';

  @override
  String get chatInsertRemoteReference => '插入远程 @file 引用';

  @override
  String get chatChooseFiles => '选择文件';

  @override
  String get chatLocalFileTypes => '文档、压缩包、音频、视频或数据文件';

  @override
  String get chatIntakePending => '文件已附加；文档目录注册待完成。';

  @override
  String get chatModelAndThinking => '本对话的模型与思考强度';

  @override
  String get chatProfileDefault => '配置默认：{0}';

  @override
  String get chatCancel => '取消';

  @override
  String get chatApplyToThisChat => '应用于本对话';

  @override
  String get chatModelLoadFailed => '无法加载此配置的模型：{0}';

  @override
  String get chatOverrideApplied => '{0} • {1} 现在仅应用于本对话。';

  @override
  String get chatModelChangeFailed => '模型未更改：{0}';

  @override
  String get chatDenyFailed => '无法拒绝该命令：{0}';

  @override
  String get chatSkipQuestionFailed => '无法跳过 Hermes 提问。';

  @override
  String get chatStopFailed => '响应已在本地关闭；网关停止失败：{0}';

  @override
  String get chatSendFailed => '发送失败：{0}';

  @override
  String get chatResponding => '正在响应…';

  @override
  String get chatActions => '对话操作';

  @override
  String get chatRefresh => '刷新';

  @override
  String get chatExportShare => '导出 / 分享';

  @override
  String get chatDismiss => '忽略';

  @override
  String get chatModelButton => '{0} • {1}';

  @override
  String get chatThisChatScope => '本对话';

  @override
  String get chatProfileDefaultScope => '配置默认';

  @override
  String get chatMessageField => '消息';

  @override
  String get chatMessageHint => '给 Hermes 发送消息…';

  @override
  String get chatSpokenReplies => '语音播报';

  @override
  String get chatStopResponse => '停止响应';

  @override
  String get chatSend => '发送';

  @override
  String get chatLoadFailedTitle => '无法加载消息';

  @override
  String get chatMessageActions => '消息操作';

  @override
  String get chatMessageCopied => '消息已复制';

  @override
  String get chatCopyMessage => '复制消息';

  @override
  String get chatReadAloud => '朗读';

  @override
  String get chatEditAndResend => '编辑并重新发送';

  @override
  String get chatRegenerate => '重新生成回复';

  @override
  String get chatThinkingEffort => '思考强度';

  @override
  String get chatChooseModel => '选择对话模型';

  @override
  String get chatAttachmentDrafts => '附件草稿';

  @override
  String get chatAddAttachment => '添加附件';

  @override
  String get chatAttachImageOrFile => '附加图片或文件';

  @override
  String get textSizeSystemLabel => '跟随系统';

  @override
  String get textSizeSystemDescription => '完全使用 Android 无障碍文字大小。';

  @override
  String get textSizeSmallLabel => '小';

  @override
  String get textSizeSmallDescription => 'Android 文字大小的 90%。';

  @override
  String get textSizeDefaultLabel => '标准';

  @override
  String get textSizeDefaultDescription => 'Android 文字大小的 100%。';

  @override
  String get textSizeLargeLabel => '大';

  @override
  String get textSizeLargeDescription => 'Android 文字大小的 115%。';

  @override
  String get textSizeExtraLargeLabel => '特大';

  @override
  String get textSizeExtraLargeDescription => 'Android 文字大小的 130%。';

  @override
  String get moreSectionWorkspace => '工作区';
  @override
  String get moreSectionOrganization => '整理';
  @override
  String get moreSectionAutomation => '自动化';
  @override
  String get moreSectionSystem => '系统';
  @override
  String get moreUnassignedChatsTitle => '未分类的会话';
  @override
  String get moreUnassignedChatsSubtitle => '未归入任何项目的会话';
  @override
  String get moreArchivedQuickTitle => '已归档的临时会话';
  @override
  String get moreArchivedQuickSubtitle => '查看或升级超过保留期的临时会话';
  @override
  String get moreFilesTitle => '文件';
  @override
  String get moreFilesSubtitle => '浏览项目背后的 miniserver 文件夹';
  @override
  String get moreAssetsTitle => '资源';
  @override
  String get moreAssetsSubtitle => '产物、附件与生成的媒体';
  @override
  String get morePinBatchUndoTitle => '置顶、批量与撤销';
  @override
  String get morePinBatchUndoSubtitle => '跨设备排序，可撤销的批量整理';
  @override
  String get moreAiFilingTitle => 'AI 辅助归档';
  @override
  String get moreAiFilingSubtitle => '推荐项目，并从你的修正中学习';
  @override
  String get moreCronTitle => '定时任务';
  @override
  String get moreCronSubtitle => '定时任务及其最近运行记录';
  @override
  String get moreSkillsTitle => '技能与工具';
  @override
  String get moreSkillsSubtitle => 'Hermes 会做什么';
  @override
  String get moreMemoryTitle => '记忆';
  @override
  String get moreMemorySubtitle => 'Hermes 长期记住的关于你的事实';
  @override
  String get moreSettingsTitle => '设置';
  @override
  String get moreSettingsSubtitle => '连接、外观与设备偏好';
  @override
  String get moreDashboardTitle => '打开 Hermes 仪表盘';
  @override
  String get moreDashboardSubtitle => '尚未原生实现的功能，都在需登录的网页仪表盘里';
  @override
  String get moreDashboardRequired => '需要可访问的 Hermes 仪表盘。请检查此连接的主机、端口和凭据。';
  @override
  String get moreGatewayAssetsRequired =>
      '需要 Hermes Gateway 提供服务端权威的 Assets 索引。';
  @override
  String get moreGatewayOrganizationRequired =>
      '需要 Hermes Gateway 提供持久的置顶排序、批量变更与撤销契约。';
  @override
  String get moreGatewayAiFilingRequired => '需要 Hermes Gateway 提供能感知修正的归档契约。';
  @override
  String get activityAndCountMore => '还有 {0} 项';
  @override
  String get activityOfflineBanner => '离线 —— 显示最近一次获取到的动态。';
  @override
  String get activityReadFailed => '无法读取动态';

  @override
  String get activityReadFailedMessage =>
      '动态通过读取持久化的回合日志来了解 Hermes 正在做什么。请确认网关可访问后重试。';

  @override
  String get connProxySectionTitle => '自定义代理与仪表盘详情';

  @override
  String get connProxyIntro =>
      '用于托管路径前缀，以及设置、记忆、技能和定时任务这几个页签。公开的仪表盘请把用户名和密码留空；若你的反向代理会注入仪表盘鉴权，请开启代理模式。';

  @override
  String get connGatewayPrefixLabel => 'Gateway 路径前缀';

  @override
  String get connGatewayPrefixHintProfile => '例如 /profile/peter';

  @override
  String get connGatewayPrefixHintProxy =>
      '例如 /profile/peter（/api/ 与 /v1/ 之前的代理路径）';

  @override
  String get connDashboardPrefixLabel => 'Dashboard 路径前缀';

  @override
  String get connDashboardPrefixHint => '例如 /dashboard';

  @override
  String get connDashboardPrefixHintProxy => '例如 /dashboard（/api/ 之前的代理路径）';

  @override
  String get connDashboardBehindProxy => '仪表盘位于反向代理之后';

  @override
  String get connDashboardBehindProxySub => '由代理注入鉴权；应用发送干净请求';

  @override
  String get connDashboardBehindProxySubNginx => '由 Nginx 注入鉴权 —— 应用发送干净请求';

  @override
  String get connDashPortLabel => 'Dashboard 端口';

  @override
  String get connDashPortHint => '留空则使用默认端口（9119）';

  @override
  String get connDashPortOptionalNote =>
      '可选。用于记忆/定时任务/技能/设置这几个页签。留空则使用默认仪表盘端口（9119）且无需登录。';

  @override
  String get connUsernameOptional => '用户名（可选）';

  @override
  String get connPasswordOptional => '密码（可选）';

  @override
  String get connDashUsernameOptional => 'Dashboard 用户名（可选）';

  @override
  String get connDashPasswordOptional => 'Dashboard 密码（可选）';

  @override
  String get connDesktopGatewayUrl => 'Desktop Gateway URL（可选）';

  @override
  String get connDesktopGatewayUrlHint => 'https://hermes-desktop.example.lan';

  @override
  String get connDesktopGatewayUrlHelper => '通过 Desktop 远程网关启用文件附件。';

  @override
  String get connHermesProfile => 'Hermes 配置（可选）';

  @override
  String get connHermesProfileHint => '例如 sol';

  @override
  String get connHermesProfileHelper =>
      '当仪表盘提供多个配置时，此连接以哪个配置的身份对话。留空则使用独立的按配置隔离的仪表盘。';

  @override
  String get connDashboardProxySettings => 'Dashboard / 代理设置';

  // ---- Gateway activity & turn status (P1 batch 7) ----

  @override
  String get activityToolPhaseRunning => '运行中';

  @override
  String get activityToolPhasePreparing => '准备中';

  @override
  String get activityToolPhaseWorking => '处理中';

  @override
  String get activityToolPhaseCompleted => '已完成';

  @override
  String get activityToolPhaseFailed => '失败';

  @override
  String get activityToolCompletedIn => '{0} 完成';

  @override
  String get activityToolFailedAfter => '{0} 后失败';

  @override
  String get activityDurationMilliseconds => '{0} 毫秒';

  @override
  String get activityDurationSeconds => '{0} 秒';

  @override
  String get activityToolFallbackName => '工具';

  @override
  String get activityToolLabel => '工具活动';

  @override
  String get activityTurnCompacting => '正在压缩会话上下文…';

  @override
  String get activityTurnCompacted => '会话上下文已压缩';

  @override
  String get activityTurnUsingTool => '正在使用 {0}…';

  @override
  String get activityToolRowLabel => '{0}：{1}';

  @override
  String get activityCardUsingOneTool => 'Hermes 正在使用 1 个工具';

  @override
  String get activityCardUsingTools => 'Hermes 正在使用 {0} 个工具';

  @override
  String get activityCardSomeFailed => '{0} 个失败 • 共 {1} 个';

  @override
  String get activityCardAllCompleted => '{0} 个完成';

  @override
  String get activityEmptyTitleRunning => '暂无正在运行的内容';

  @override
  String get activityEmptyMessageRunning => '没有回合被阻塞、进行中或刚刚结束。你启动的工作会显示在这里。';

  @override
  String get activityEmptyTitleActionable => '收件箱是空的';

  @override
  String get activityEmptyMessageActionable => '没有回合需要你的输入，也没有失败的回合。';
}

/// Publishes the resolved [AppStrings] to a subtree.
///
/// Installed once by `MaterialApp.builder` in `main.dart`, so every screen —
/// including one reached through a route pushed before a language switch —
/// rebuilds with new strings when the user picks a different language.
class AppStringsScope extends InheritedWidget {
  const AppStringsScope({
    required this.strings,
    required super.child,
    super.key,
  });

  /// The strings for the current interface language.
  final AppStrings strings;

  @override
  bool updateShouldNotify(AppStringsScope oldWidget) =>
      oldWidget.strings != strings;
}
