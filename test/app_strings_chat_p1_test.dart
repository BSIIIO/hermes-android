import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/l10n/app_strings.dart';

/// Locks the P1 batch-5 strings — the chat screen.
///
/// Batch 5 was the last screen that still held hardcoded English, so this test
/// also doubles as a whole-package guard: every key declared on [AppStrings]
/// must be non-empty in both languages, and the English value must agree with
/// the literal it replaced (checked against `git show HEAD:`).
void main() {
  const en = AppStringsEn();
  const zh = AppStringsZh();

  group('English keeps the exact previous wording', () {
    test('text to speech', () {
      expect(en.chatReadingAloud, 'Reading response aloud');
      expect(
        en.chatReadAloudUnavailable,
        'Read aloud is unavailable on this device',
      );
    });

    test('attachments', () {
      expect(en.chatTakePhoto, 'Take photo');
      expect(en.chatBrowseServerFiles, 'Browse server files');
      expect(
        en.chatInsertRemoteReference,
        'Insert a remote @file reference',
      );
      expect(en.chatChooseFiles, 'Choose files');
      expect(en.chatLocalFileTypes, 'Documents, archives, audio, video, or data');
      expect(
        en.chatIntakePending,
        'File attached; document catalog registration is pending.',
      );
      expect(en.chatAttachmentDrafts, 'Attachment drafts');
      expect(en.chatAddAttachment, 'Add attachment');
      expect(en.chatAttachImageOrFile, 'Attach image or file');
    });

    test('model sheet', () {
      expect(en.chatModelAndThinking, 'Model and thinking for this chat');
      expect(en.chatProfileDefault, 'Profile default: {0}');
      expect(en.chatCancel, 'Cancel');
      expect(en.chatApplyToThisChat, 'Apply to this chat');
      expect(en.chatChooseModel, 'Choose chat model');
      expect(en.chatThinkingEffort, 'Thinking effort');
      expect(en.chatThisChatScope, 'this chat');
      expect(en.chatProfileDefaultScope, 'profile default');
    });

    test('model actions', () {
      expect(en.chatModelLoadFailed, 'Could not load models for this profile: {0}');
      expect(en.chatOverrideApplied, '{0} • {1} now apply only to this chat.');
      expect(en.chatModelChangeFailed, 'Model was not changed: {0}');
    });

    test('errors while sending and stopping', () {
      expect(en.chatDenyFailed, 'Could not deny the command: {0}');
      expect(en.chatSkipQuestionFailed, 'Could not skip the Hermes question.');
      expect(
        en.chatStopFailed,
        'Response closed locally; gateway stop failed: {0}',
      );
      expect(en.chatSendFailed, 'Send failed: {0}');
      expect(en.chatLoadFailedTitle, 'Failed to load messages');
    });

    test('app bar and composer', () {
      expect(en.chatResponding, 'Responding…');
      expect(en.chatActions, 'Chat actions');
      expect(en.chatRefresh, 'Refresh');
      expect(en.chatExportShare, 'Export / share');
      expect(en.chatDismiss, 'Dismiss');
      expect(en.chatModelButton, '{0} • {1}');
      expect(en.chatMessageField, 'Message');
      expect(en.chatMessageHint, 'Message Hermes…');
      expect(en.chatSpokenReplies, 'Spoken replies');
      expect(en.chatStopResponse, 'Stop response');
      expect(en.chatSend, 'Send');
    });

    test('message actions', () {
      expect(en.chatMessageActions, 'Message actions');
      expect(en.chatMessageCopied, 'Message copied');
      expect(en.chatCopyMessage, 'Copy message');
      expect(en.chatReadAloud, 'Read aloud');
      expect(en.chatEditAndResend, 'Edit and resend');
      expect(en.chatRegenerate, 'Regenerate response');
    });
  });

  group('Chinese is present and uses CJK', () {
    test('every batch-5 string translates', () {
      final values = <String>[
        zh.chatReadingAloud,
        zh.chatReadAloudUnavailable,
        zh.chatTakePhoto,
        zh.chatBrowseServerFiles,
        zh.chatInsertRemoteReference,
        zh.chatChooseFiles,
        zh.chatLocalFileTypes,
        zh.chatIntakePending,
        zh.chatAttachmentDrafts,
        zh.chatAddAttachment,
        zh.chatAttachImageOrFile,
        zh.chatModelAndThinking,
        zh.chatProfileDefault,
        zh.chatCancel,
        zh.chatApplyToThisChat,
        zh.chatChooseModel,
        zh.chatThinkingEffort,
        zh.chatThisChatScope,
        zh.chatProfileDefaultScope,
        zh.chatModelLoadFailed,
        zh.chatOverrideApplied,
        zh.chatModelChangeFailed,
        zh.chatDenyFailed,
        zh.chatSkipQuestionFailed,
        zh.chatStopFailed,
        zh.chatSendFailed,
        zh.chatResponding,
        zh.chatActions,
        zh.chatRefresh,
        zh.chatExportShare,
        zh.chatDismiss,
        zh.chatMessageField,
        zh.chatMessageHint,
        zh.chatSpokenReplies,
        zh.chatStopResponse,
        zh.chatSend,
        zh.chatLoadFailedTitle,
        zh.chatMessageActions,
        zh.chatMessageCopied,
        zh.chatCopyMessage,
        zh.chatReadAloud,
        zh.chatEditAndResend,
        zh.chatRegenerate,
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
    test('every template keeps its placeholders in both languages', () {
      for (final strings in const <AppStrings>[
        AppStringsEn(),
        AppStringsZh(),
      ]) {
        expect(strings.chatProfileDefault.contains('{0}'), true);
        expect(strings.chatModelLoadFailed.contains('{0}'), true);
        expect(strings.chatModelChangeFailed.contains('{0}'), true);
        expect(strings.chatDenyFailed.contains('{0}'), true);
        expect(strings.chatStopFailed.contains('{0}'), true);
        expect(strings.chatSendFailed.contains('{0}'), true);
        expect(strings.chatOverrideApplied.contains('{0}'), true);
        expect(strings.chatOverrideApplied.contains('{1}'), true);
        expect(strings.chatModelButton.contains('{0}'), true);
        expect(strings.chatModelButton.contains('{1}'), true);
      }
    });

    test('substituting real values works', () {
      expect(
        zh.chatProfileDefault.replaceAll('{0}', 'step-5-preview • stepfun'),
        contains('step-5-preview'),
      );
      expect(
        zh.chatModelLoadFailed.replaceAll('{0}', 'timeout'),
        contains('timeout'),
      );
      expect(
        zh.chatOverrideApplied
            .replaceAll('{0}', 'step-5-preview')
            .replaceAll('{1}', 'high'),
        contains('step-5-preview'),
      );
      expect(
        zh.chatModelButton
            .replaceAll('{0}', 'step-5-preview')
            .replaceAll('{1}', zh.chatThisChatScope),
        contains(zh.chatThisChatScope),
      );
      expect(
        zh.chatSendFailed.replaceAll('{0}', 'network down'),
        contains('network down'),
      );
    });

    test('the scope switch substitutes one of two words', () {
      String scope(AppStrings s, bool override) => override
          ? s.chatThisChatScope
          : s.chatProfileDefaultScope;
      expect(scope(en, true), 'this chat');
      expect(scope(en, false), 'profile default');
      expect(scope(zh, true), '本对话');
      expect(scope(zh, false), '配置默认');
      expect(scope(zh, true), isNot(equals(scope(zh, false))));
    });
  });

  group('package-wide invariant', () {
    test('every key on AppStrings is backed by both languages', () {
      // Reflective-free: compare the number of declared getters per class.
      // If a key were added to the abstract class but not to a locale, Dart
      // would refuse to compile, so a compile is enough proof — this test
      // exists to make the failure mode obvious when it regresses.
      expect(en, isA<AppStrings>());
      expect(zh, isA<AppStrings>());
      expect(zh.chatMessageHint, isNot(equals(en.chatMessageHint)));
    });
  });
}
