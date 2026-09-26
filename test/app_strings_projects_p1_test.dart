import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/l10n/app_strings.dart';

/// Locks the P1 batch-3 strings — the Projects pane and the project detail
/// screen.
///
/// Two invariants are defended:
///
///  * [AppStringsEn] is byte-identical to the literals that used to be
///    hardcoded in `projects_pane.dart` / `project_detail_screen.dart`, so an
///    English user sees no visual change. Rewording a label while adding a key
///    fails here.
///  * The Chinese values are non-empty and contain CJK.
///
/// Placeholders must survive in BOTH implementations — dropping one is
/// invisible at compile time and only shows as a raw `{0}` on screen at
/// runtime.
void main() {
  const en = AppStringsEn();
  const zh = AppStringsZh();

  group('English keeps the exact previous wording', () {
    test('projects pane: sections, chips, and actions', () {
      expect(en.projectsTitle, 'Projects');
      expect(en.projectsArchived, 'Archived');
      expect(en.projectsActive, 'Active');
      expect(en.projectsActions, 'Project actions');
      expect(en.projectsRename, 'Rename project');
      expect(en.projectsArchive, 'Archive project');
      expect(en.projectsRestore, 'Restore project');
      expect(en.projectsOnThisDevice, 'On this device');
      expect(en.projectsReviewLocalSpaces, 'Review local spaces');
    });

    test('projects pane: empty, error, and offline states', () {
      expect(en.projectsEmptyTitle, 'No projects yet');
      expect(
        en.projectsEmptyMessage,
        'Projects group related chats, files, and activity, and stay in sync '
        'with Hermes on your computer.',
      );
      expect(en.projectsCreateAction, 'Create a project');
      expect(en.projectsNewProject, 'New project');
      expect(en.projectsUnreachableTitle, 'Could not reach Hermes');
      expect(
        en.projectsUnreachableMessage,
        'Check that the gateway is running and reachable, then try again.',
      );
      expect(
        en.projectsOfflineBanner,
        'Offline — showing the last known projects.',
      );
    });

    test('projects pane: compatibility mode', () {
      expect(en.projectsCompatibilityMode, 'Compatibility mode');
      expect(
        en.projectsCompatibilityExplanation,
        'This Hermes gateway is older than server-side projects, so chats stay '
        'grouped on this device only. Update Hermes to share the same projects '
        'across your devices.',
      );
      expect(en.projectsNoLocalSpacesTitle, 'No spaces on this device');
      expect(
        en.projectsNoLocalSpacesMessage,
        'Chats from this gateway are not grouped yet. Grouping stays on this '
        'phone until the gateway can host projects.',
      );
    });

    test('projects pane: local space counts and plurals', () {
      expect(en.projectsLocalSpaceSubtitle, '{0} · on this device only');
      expect(en.projectsOneChat, '1 chat');
      expect(en.projectsChatCount, '{0} chats');
    });

    test('projects pane: create and rename dialogs', () {
      expect(en.projectsNewDialogTitle, 'New project');
      expect(en.projectsCreate, 'Create');
      expect(en.projectsNameLabel, 'Name');
      expect(en.projectsNameRequired, 'Enter a name');
      expect(en.projectsRenameDialogTitle, 'Rename {0}');
      expect(en.projectsRenameAction, 'Rename');
      expect(en.projectsArchiveConfirmTitle, 'Archive {0}?');
      expect(
        en.projectsArchiveConfirmBody,
        'The Project will move to Archived. Its chats and files stay intact, '
        'and you can restore it at any time.',
      );
      expect(en.projectsArchiveConfirmAction, 'Archive');
      expect(en.commonCancel, 'Cancel');
    });

    test('projects pane: mutation errors', () {
      expect(en.projectsMutationFailed, 'Could not {0} the project: {1}');
      expect(en.projectsActionCreate, 'create');
      expect(en.projectsActionRename, 'rename');
      expect(en.projectsActionArchive, 'archive');
      expect(en.projectsActionRestore, 'restore');
    });

    test('project detail: tabs, FAB, and menu', () {
      expect(en.projectDetailChats, 'Chats');
      expect(en.projectDetailTabOverview, 'Overview');
      expect(en.projectDetailTabFiles, 'Files');
      expect(en.projectDetailTabAssets, 'Assets');
      expect(en.projectDetailTabActivity, 'Activity');
      expect(en.projectDetailNewChat, 'New chat');
      expect(en.projectDetailDeleteProject, 'Delete project');
      expect(en.commonRetryShort, 'Retry');
    });

    test('project detail: search and chat states', () {
      expect(en.projectDetailSearchChats, 'Search chats');
      expect(en.projectDetailClearSearch, 'Clear search');
      expect(en.projectDetailNoChatsTitle, 'No chats yet');
      expect(
        en.projectDetailNoChatsMessage,
        'Chats you start in this project will appear here, on every device '
        'signed in to this Hermes.',
      );
      expect(en.projectDetailNoMatchesTitle, 'No matches');
      expect(
        en.projectDetailNoMatchesMessage,
        'No chats in this project match “{0}”.',
      );
    });

    test('project detail: overview, folders, assets', () {
      expect(en.projectDetailConversations, 'Conversations in this project');
      expect(en.projectDetailRepositories, 'Repositories');
      expect(en.projectDetailLocation, 'Location');
      expect(en.projectDetailFolders, 'Folders');
      expect(en.projectDetailNoFoldersTitle, 'No folders yet');
      expect(
        en.projectDetailNoFoldersMessage,
        'The server has not reported folders for this project yet. Global Files '
        'stays available from More.',
      );
      expect(en.projectDetailAssetsUnavailableTitle, 'Assets unavailable');
      expect(
        en.projectDetailAssetsUnavailableMessage,
        'Assets need a server-authoritative Assets index in the Hermes Gateway '
        'before they can be shown per project.',
      );
      expect(en.projectDetailNoActivityTitle, 'No activity yet');
      expect(
        en.projectDetailNoActivityMessage,
        'Chats in this project will show their state and last activity here.',
      );
      expect(
        en.projectDetailOfflineBanner,
        'Offline — showing the last known chats',
      );
    });

    test('project detail: move and dialogs', () {
      expect(en.projectDetailMoveConversation, 'Move conversation');
      expect(en.projectDetailUnassigned, 'Unassigned');
      expect(en.projectDetailMovedTo, 'Moved to {0}');
      expect(en.projectDetailMoveFailed, 'Couldn’t move conversation');
      expect(en.projectDetailRenameTitle, 'Rename {0}');
      expect(en.projectDetailRename, 'Rename');
      expect(en.projectDetailArchiveConfirmTitle, 'Archive {0}?');
      expect(
        en.projectDetailArchiveConfirmBody,
        'The Project will move to Archived. Its chats and files stay intact, '
        'and you can restore it later.',
      );
      expect(en.projectDetailArchive, 'Archive');
      expect(en.projectDetailDeleteConfirmTitle, 'Delete {0}?');
      expect(
        en.projectDetailDeleteConfirmBody,
        'This permanently deletes the Project. Chats will not be deleted; '
        'they’ll return to Unassigned.',
      );
      expect(en.projectDetailDelete, 'Delete');
      expect(en.projectDetailManageFailed, 'Couldn’t {0} project');
      expect(en.projectDetailDeleteFailed, 'Couldn’t delete project');
    });

    test('project detail: gateway support errors', () {
      expect(en.projectDetailUnsupportedTitle, 'Project chats unavailable');
      expect(
        en.projectDetailUnsupportedMessage,
        'This Hermes gateway does not support opening a project yet. Update '
        'Hermes on the server to browse a project from your phone.',
      );
      expect(en.projectDetailOpenFailedTitle, 'Could not open this project');
      expect(
        en.projectDetailOpenFailedMessage,
        'Check that the gateway is running and reachable, then try again.',
      );
    });
  });

  group('Chinese is present and uses CJK', () {
    test('every batch-3 string translates', () {
      final values = <String>[
        // Projects pane
        zh.projectsTitle,
        zh.projectsArchived,
        zh.projectsActive,
        zh.projectsActions,
        zh.projectsRename,
        zh.projectsArchive,
        zh.projectsRestore,
        zh.projectsEmptyTitle,
        zh.projectsEmptyMessage,
        zh.projectsCreateAction,
        zh.projectsNewProject,
        zh.projectsNewDialogTitle,
        zh.projectsCreate,
        zh.projectsNameLabel,
        zh.projectsNameRequired,
        zh.projectsArchiveConfirmTitle,
        zh.projectsArchiveConfirmBody,
        zh.projectsArchiveConfirmAction,
        zh.projectsRenameDialogTitle,
        zh.projectsRenameAction,
        zh.projectsMutationFailed,
        zh.projectsActionCreate,
        zh.projectsActionRename,
        zh.projectsActionArchive,
        zh.projectsActionRestore,
        zh.projectsUnreachableTitle,
        zh.projectsUnreachableMessage,
        zh.projectsOfflineBanner,
        zh.projectsLocalSpaceSubtitle,
        zh.projectsOneChat,
        zh.projectsChatCount,
        zh.projectsCompatibilityMode,
        zh.projectsCompatibilityExplanation,
        zh.projectsNoLocalSpacesTitle,
        zh.projectsNoLocalSpacesMessage,
        zh.projectsOnThisDevice,
        zh.projectsReviewLocalSpaces,
        // Project detail
        zh.projectDetailMoveConversation,
        zh.projectDetailUnassigned,
        zh.projectDetailMovedTo,
        zh.projectDetailMoveFailed,
        zh.commonRetryShort,
        zh.projectDetailRenameTitle,
        zh.projectDetailRename,
        zh.projectDetailArchiveConfirmTitle,
        zh.projectDetailArchiveConfirmBody,
        zh.projectDetailArchive,
        zh.projectDetailDeleteConfirmTitle,
        zh.projectDetailDeleteConfirmBody,
        zh.projectDetailDelete,
        zh.projectDetailManageFailed,
        zh.projectDetailDeleteFailed,
        zh.projectDetailNewChat,
        zh.projectDetailChats,
        zh.projectDetailTabOverview,
        zh.projectDetailTabFiles,
        zh.projectDetailTabAssets,
        zh.projectDetailTabActivity,
        zh.projectDetailDeleteProject,
        zh.projectDetailConversations,
        zh.projectDetailRepositories,
        zh.projectDetailLocation,
        zh.projectDetailFolders,
        zh.projectDetailNoFoldersTitle,
        zh.projectDetailNoFoldersMessage,
        zh.projectDetailAssetsUnavailableTitle,
        zh.projectDetailAssetsUnavailableMessage,
        zh.projectDetailNoActivityTitle,
        zh.projectDetailNoActivityMessage,
        zh.projectDetailSearchChats,
        zh.projectDetailClearSearch,
        zh.projectDetailNoChatsTitle,
        zh.projectDetailNoChatsMessage,
        zh.projectDetailNoMatchesTitle,
        zh.projectDetailNoMatchesMessage,
        zh.projectDetailUnsupportedTitle,
        zh.projectDetailUnsupportedMessage,
        zh.projectDetailOpenFailedTitle,
        zh.projectDetailOpenFailedMessage,
        zh.projectDetailOfflineBanner,
        zh.commonCancel,
      ];
      for (final value in values) {
        expect(value.isNotEmpty, true, reason: 'empty translation found');
        expect(
          RegExp(r'[\u4e00-\u9fff]').hasMatch(value),
          true,
          reason: 'no CJK in "$value" — a copy of the English text, not a '
              'translation',
        );
      }
    });
  });

  group('interpolation is language-agnostic', () {
    test('two-placeholder mutation error keeps {0} and {1}', () {
      for (final strings in const <AppStrings>[
        AppStringsEn(),
        AppStringsZh(),
      ]) {
        expect(
          strings.projectsMutationFailed.contains('{0}'),
          true,
          reason: '${strings.runtimeType} lost {0}',
        );
        expect(
          strings.projectsMutationFailed.contains('{1}'),
          true,
          reason: '${strings.runtimeType} lost {1}',
        );
      }
    });

    test('every {0} template substitutes', () {
      expect(
        zh.projectsArchiveConfirmTitle.replaceAll('{0}', 'My Project'),
        contains('My Project'),
      );
      expect(
        zh.projectsRenameDialogTitle.replaceAll('{0}', 'My Project'),
        contains('My Project'),
      );
      expect(
        zh.projectsChatCount.replaceAll('{0}', '4'),
        contains('4'),
      );
      expect(
        zh.projectsLocalSpaceSubtitle.replaceAll('{0}', '3 个会话'),
        contains('3 个会话'),
      );
      expect(
        zh.projectDetailRenameTitle.replaceAll('{0}', 'My Project'),
        contains('My Project'),
      );
      expect(
        zh.projectDetailArchiveConfirmTitle.replaceAll('{0}', 'My Project'),
        contains('My Project'),
      );
      expect(
        zh.projectDetailDeleteConfirmTitle.replaceAll('{0}', 'My Project'),
        contains('My Project'),
      );
      expect(
        zh.projectDetailMovedTo.replaceAll('{0}', 'Other'),
        contains('Other'),
      );
      expect(
        zh.projectDetailManageFailed.replaceAll('{0}', '归档'),
        contains('归档'),
      );
      expect(
        zh.projectDetailNoMatchesMessage.replaceAll('{0}', 'query'),
        contains('query'),
      );
      expect(
        zh.projectsMutationFailed
            .replaceAll('{0}', zh.projectsActionArchive)
            .replaceAll('{1}', 'boom'),
        contains('boom'),
      );
    });
  });
}
