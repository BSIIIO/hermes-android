import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/l10n/app_strings.dart';

/// Locks the P1 batch-2 strings — the Chats drawer, statuses, search UI and
/// session action flows.
///
/// Two invariants are defended:
///
///  * [AppStringsEn] is byte-identical to the literals that used to be
///    hardcoded in `session_list_screen.dart`, so an English user sees no
///    visual change. Rewording a label while adding a key fails here.
///  * The Chinese values are non-empty and contain CJK.
///
/// Placeholders are interpolated at runtime for values whose position differs
/// between the two languages, so `{0}` / `{1}` must survive in BOTH
/// implementations — that is asserted separately here.
void main() {
  const en = AppStringsEn();
  const zh = AppStringsZh();

  group('English keeps the exact previous wording', () {
    test('drawer menu', () {
      expect(en.drawerSpaces, 'Spaces');
      expect(en.drawerWorkspace, 'Workspace');
      expect(en.drawerMemory, 'Memory');
      expect(en.drawerCronJobs, 'Cron Jobs');
      expect(en.drawerSkills, 'Skills');
      expect(en.drawerSettings, 'Settings');
    });

    test('connection statuses and empty state', () {
      expect(en.chatsConnecting, 'Connecting to {0}...');
      expect(
        en.chatsConnectingHint,
        'Make sure the Gateway API Server is running\n'
        '(hermes gateway status)',
      );
      expect(en.chatsConnectionIssue, 'Connection issue');
      expect(en.commonRetry, 'Retry');
      expect(en.chatsNoSessions, 'No sessions yet');
      expect(
        en.chatsNoSessionsHint,
        'Tap the + button to start a new chat',
      );
    });

    test('session row and actions', () {
      expect(en.chatsActions, 'Chat actions');
      expect(en.chatsUntitledSession, 'Untitled session');
      expect(en.chatsRowMeta, '{0} msgs \u2022 {1} \u2022 {2}');
      expect(en.chatsDeleteSessionTitle, 'Delete session?');
      expect(
        en.chatsDeleteSessionBody,
        'Delete "{0}" from the remote Hermes history? This cannot be undone.',
      );
      expect(en.chatsDelete, 'Delete');
      expect(en.chatsDeleted, 'Session deleted from remote Hermes.');
      expect(en.chatsDeleteFailed, 'Could not delete session: {0}');
      expect(en.chatsMoveChat, 'Move chat');
      expect(en.chatsMoveChatChoose, 'Choose its destination space');
      expect(en.chatsMoveUnassigned, 'Unassigned');
    });

    test('rename and branch flows', () {
      expect(en.chatsRenameChat, 'Rename chat');
      expect(en.chatsRename, 'Rename');
      expect(en.chatsRenameFailed, 'Could not rename chat: {0}');
      expect(en.chatsBranchChatTitle, 'Branch chat');
      expect(en.chatsBranchCreate, 'Create branch');
      expect(en.chatsBranchCreated, 'Branch created in Hermes history.');
    });

    test('profile picker', () {
      expect(en.chatsProfileHeader, 'Profile');
      expect(en.chatsSwitchProfile, 'Switch profile');
    });

    test('search field', () {
      expect(en.chatsSearchMode, 'Search mode');
      expect(en.chatsSearchHintAi, 'Ask AI to find a conversation');
      expect(en.chatsSearchHintFullText, 'Search all message content');
      expect(en.chatsSearchHintLoaded, 'Search loaded chats');
      expect(en.chatsClearSearch, 'Clear search');
      expect(en.chatsSearchAiSearchedFor, 'AI searched for: {0}');
      expect(en.chatsSearchOnDevice, 'On-device');
      expect(en.chatsSearchOnDeviceDetail, 'Titles, previews, and models');
      expect(en.chatsSearchFullText, 'Full-text');
      expect(en.chatsSearchFullTextDetail, 'All stored message content');
      expect(en.chatsSearchUseOnDevice, 'Use on-device');
      expect(en.chatsSearchAiFullTextTitle, 'AI + full-text');
      expect(
        en.chatsSearchAiChooseModel,
        'Choose a small model to rewrite queries',
      );
    });

    test('AI search model sheet', () {
      expect(en.chatsAiModelTitle, 'AI search model');
      expect(
        en.chatsAiModelDescription,
        'The model only rewrites your question into a short full-text query. '
            'Hermes uses the provider credentials already configured on the '
            'host.',
      );
      expect(en.chatsAiModelLoadFailed, 'Could not load AI search models: {0}');
    });
  });

  group('Chinese is present and uses CJK', () {
    test('every batch-2 string translates', () {
      final values = <String>[
        zh.drawerSpaces,
        zh.drawerWorkspace,
        zh.drawerMemory,
        zh.drawerCronJobs,
        zh.drawerSkills,
        zh.drawerSettings,
        zh.chatsConnecting,
        zh.chatsConnectingHint,
        zh.chatsConnectionIssue,
        zh.commonRetry,
        zh.chatsNoSessions,
        zh.chatsNoSessionsHint,
        zh.chatsActions,
        zh.chatsUntitledSession,
        zh.chatsRowMeta,
        zh.chatsDeleteSessionTitle,
        zh.chatsDeleteSessionBody,
        zh.chatsDelete,
        zh.chatsDeleted,
        zh.chatsDeleteFailed,
        zh.chatsMoveChat,
        zh.chatsMoveChatChoose,
        zh.chatsMoveUnassigned,
        zh.chatsRenameChat,
        zh.chatsRename,
        zh.chatsRenameFailed,
        zh.chatsBranchChatTitle,
        zh.chatsBranchCreate,
        zh.chatsBranchCreated,
        zh.chatsProfileHeader,
        zh.chatsSwitchProfile,
        zh.chatsSearchMode,
        zh.chatsSearchHintAi,
        zh.chatsSearchHintFullText,
        zh.chatsSearchHintLoaded,
        zh.chatsClearSearch,
        zh.chatsSearchAiSearchedFor,
        zh.chatsSearchOnDevice,
        zh.chatsSearchOnDeviceDetail,
        zh.chatsSearchFullText,
        zh.chatsSearchFullTextDetail,
        zh.chatsSearchUseOnDevice,
        zh.chatsSearchAiFullTextTitle,
        zh.chatsSearchAiChooseModel,
        zh.chatsAiModelTitle,
        zh.chatsAiModelDescription,
        zh.chatsAiModelLoadFailed,
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
    test('multi-placeholder templates keep {0} and {1}', () {
      for (final strings in const <AppStrings>[
        AppStringsEn(),
        AppStringsZh(),
      ]) {
        expect(
          strings.chatsRowMeta.contains('{0}'),
          true,
          reason: '${strings.runtimeType}.chatsRowMeta lost {0}',
        );
        expect(
          strings.chatsRowMeta.contains('{1}'),
          true,
          reason: '${strings.runtimeType}.chatsRowMeta lost {1}',
        );
      }
    });

    test('every {0} template substitutes', () {
      expect(
        zh.chatsConnecting.replaceAll('{0}', 'https://example.test'),
        contains('https://example.test'),
      );
      expect(
        zh.chatsDeleteFailed.replaceAll('{0}', 'boom'),
        contains('boom'),
      );
      expect(
        zh.chatsAiModelLoadFailed.replaceAll('{0}', 'boom'),
        contains('boom'),
      );
      expect(
        zh.chatsRenameFailed.replaceAll('{0}', 'boom'),
        contains('boom'),
      );
      expect(
        zh.chatsDeleteSessionBody.replaceAll('{0}', 'My chat'),
        contains('My chat'),
      );
      expect(
        zh.chatsRowMeta
            .replaceAll('{0}', '7')
            .replaceAll('{1}', 'deepseek')
            .replaceAll('{2}', '10:00'),
        contains('7'),
      );
    });
  });
}
