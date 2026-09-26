import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/l10n/app_strings.dart';

/// Locks the English values of the chat-screen strings that were hoisted out of
/// `chat_screen.dart` in the i18n batches.
///
/// The point is not to test the Chinese — it is to guarantee that the English
/// value is still character-for-character the literal that used to live in the
/// widget. When a translation edit accidentally rewrites the English side, a
/// reviewer comparing against git history would otherwise have to notice it by
/// eye. Any value here must match the original source exactly, including
/// capitalization, punctuation, the ellipsis character and the trailing space
/// in templates.
void main() {
  const en = AppStringsEn();
  const zh = AppStringsZh();

  group('chat screen: English parity with the pre-i18n literals', () {
    test('reasoning effort labels', () {
      expect(en.chatReasoningEffortOff, 'Off (no thinking)');
      expect(en.chatReasoningEffortExtraHigh, 'Extra High');
    });

    test('transport and voice', () {
      expect(
        en.chatLegacyTransportNotice,
        'Background recovery unavailable — legacy transport',
      );
      expect(en.chatVoiceSetupFailed, 'Voice setup failed: {0}');
      expect(
        en.chatSpeechRecognitionUnavailable,
        'Speech recognition is unavailable',
      );
      expect(en.chatSpokenRepliesOn, 'Spoken replies on');
      expect(en.chatSpokenRepliesOff, 'Spoken replies off');
    });

    test('turn summaries', () {
      expect(en.chatResponseReady, 'Response ready');
      expect(en.chatTurnCompleted, 'Turn completed');
      expect(en.chatResponseStopped, 'Response stopped.');
      expect(
        en.chatResponseClosedLocally,
        'Response closed locally; no active gateway turn was found.',
      );
    });

    test('recovery statuses', () {
      expect(en.chatRecoveryWaitingInput, 'Hermes is waiting for input…');
      expect(en.chatRecoveryResponding, 'Hermes is responding…');
      expect(en.chatRecoveryRestarting, 'Recovering Hermes…');
      expect(en.chatRecoveryFailed, 'Recovering Hermes failed…');
      expect(en.chatRecoveryUnavailable, 'Hermes recovery is unavailable: {0}');
      expect(
        en.chatRecoveryStoppedSafely,
        'Hermes stopped recovery safely. No prompt was resent.',
      );
      expect(
        en.chatDeliveryUncertain,
        'Delivery is uncertain; recovering without resending…',
      );
    });

    test('attachment picker and uploads', () {
      expect(en.chatChooseImage, 'Choose image');
      expect(en.chatChooseImages, 'Choose images');
      expect(en.chatStartingHermes, 'Starting Hermes…');
      expect(en.chatRetryingAttachment, 'Retrying {0}…');
      expect(en.chatPreparingAttachments, 'Preparing attachments…');
      expect(en.chatUploadingAttachment, 'Uploading {0}/{1}: {2}');
      expect(en.chatDelegatedTask, 'Delegated task: {0}');
    });

    test('attachment errors', () {
      expect(
        en.chatUnableToPrepareImage,
        'Unable to prepare this image. Try another one.',
      );
      expect(
        en.chatUnableToPrepareFile,
        'Unable to prepare this file. Try another one.',
      );
      expect(en.chatUnableToPrepareNamed, 'Unable to prepare {0}.');
      expect(
        en.chatImageSelectionInterrupted,
        'Image selection was interrupted. Try again.',
      );
      expect(
        en.chatUnableToReadImage,
        'Unable to read the selected image. The selection was kept.',
      );
      expect(
        en.chatConfigureGatewayBeforeAttaching,
        'Configure a valid Desktop Gateway URL before attaching files.',
      );
      expect(
        en.chatDesktopGatewayNotConfigured,
        'Desktop Gateway is not configured for this connection.',
      );
      expect(en.chatAttachmentLimit, 'You can attach up to {0} items.');
      expect(
        en.chatAttachmentsSkipped,
        '{0} file(s) skipped: limit, size, unreadable, or sensitive '
            'filename.',
      );
      expect(
        en.chatAttachmentRetryFailed,
        'Retry failed for {0}. The draft and prompt were kept.',
      );
    });

    test('title and composer semantics', () {
      expect(en.chatUntitled, 'Untitled chat');
      expect(en.chatStopResponse, 'Stop response');
      expect(en.chatSendMessage, 'Send message');
    });
  });

  group('chat screen: Chinese values are actually translated', () {
    test('no chat key leaves the English value untouched in Zh', () {
      // These are the wire-enum labels that are deliberately identical in both
      // locales. Anything else must differ, or the key has not been translated.
      const allowedIdentical = <String>{};
      final mismatches = <String>[];
      for (final name in <String>[
        'chatReasoningEffortOff',
        'chatReasoningEffortExtraHigh',
        'chatLegacyTransportNotice',
        'chatVoiceSetupFailed',
        'chatSpeechRecognitionUnavailable',
        'chatSpokenRepliesOn',
        'chatSpokenRepliesOff',
        'chatResponseReady',
        'chatTurnCompleted',
        'chatResponseStopped',
        'chatResponseClosedLocally',
        'chatRecoveryWaitingInput',
        'chatRecoveryResponding',
        'chatRecoveryRestarting',
        'chatRecoveryFailed',
        'chatRecoveryUnavailable',
        'chatRecoveryStoppedSafely',
        'chatDeliveryUncertain',
        'chatChooseImage',
        'chatChooseImages',
        'chatStartingHermes',
        'chatRetryingAttachment',
        'chatPreparingAttachments',
        'chatUploadingAttachment',
        'chatDelegatedTask',
        'chatUnableToPrepareImage',
        'chatUnableToPrepareFile',
        'chatUnableToPrepareNamed',
        'chatImageSelectionInterrupted',
        'chatUnableToReadImage',
        'chatConfigureGatewayBeforeAttaching',
        'chatDesktopGatewayNotConfigured',
        'chatAttachmentLimit',
        'chatAttachmentsSkipped',
        'chatAttachmentRetryFailed',
        'chatUntitled',
        'chatStopResponse',
        'chatSendMessage',
      ]) {
        final e = read(en, name);
        final z = read(zh, name);
        if (e == z && !allowedIdentical.contains(name)) {
          mismatches.add('$name: $e');
        }
      }
      expect(mismatches, isEmpty);
    });
  });
}

/// Reads a getter by name so the list above stays a flat list of strings.
String read(AppStrings s, String name) => switch (name) {
  'chatReasoningEffortOff' => s.chatReasoningEffortOff,
  'chatReasoningEffortExtraHigh' => s.chatReasoningEffortExtraHigh,
  'chatLegacyTransportNotice' => s.chatLegacyTransportNotice,
  'chatVoiceSetupFailed' => s.chatVoiceSetupFailed,
  'chatSpeechRecognitionUnavailable' => s.chatSpeechRecognitionUnavailable,
  'chatSpokenRepliesOn' => s.chatSpokenRepliesOn,
  'chatSpokenRepliesOff' => s.chatSpokenRepliesOff,
  'chatResponseReady' => s.chatResponseReady,
  'chatTurnCompleted' => s.chatTurnCompleted,
  'chatResponseStopped' => s.chatResponseStopped,
  'chatResponseClosedLocally' => s.chatResponseClosedLocally,
  'chatRecoveryWaitingInput' => s.chatRecoveryWaitingInput,
  'chatRecoveryResponding' => s.chatRecoveryResponding,
  'chatRecoveryRestarting' => s.chatRecoveryRestarting,
  'chatRecoveryFailed' => s.chatRecoveryFailed,
  'chatRecoveryUnavailable' => s.chatRecoveryUnavailable,
  'chatRecoveryStoppedSafely' => s.chatRecoveryStoppedSafely,
  'chatDeliveryUncertain' => s.chatDeliveryUncertain,
  'chatChooseImage' => s.chatChooseImage,
  'chatChooseImages' => s.chatChooseImages,
  'chatStartingHermes' => s.chatStartingHermes,
  'chatRetryingAttachment' => s.chatRetryingAttachment,
  'chatPreparingAttachments' => s.chatPreparingAttachments,
  'chatUploadingAttachment' => s.chatUploadingAttachment,
  'chatDelegatedTask' => s.chatDelegatedTask,
  'chatUnableToPrepareImage' => s.chatUnableToPrepareImage,
  'chatUnableToPrepareFile' => s.chatUnableToPrepareFile,
  'chatUnableToPrepareNamed' => s.chatUnableToPrepareNamed,
  'chatImageSelectionInterrupted' => s.chatImageSelectionInterrupted,
  'chatUnableToReadImage' => s.chatUnableToReadImage,
  'chatConfigureGatewayBeforeAttaching' => s.chatConfigureGatewayBeforeAttaching,
  'chatDesktopGatewayNotConfigured' => s.chatDesktopGatewayNotConfigured,
  'chatAttachmentLimit' => s.chatAttachmentLimit,
  'chatAttachmentsSkipped' => s.chatAttachmentsSkipped,
  'chatAttachmentRetryFailed' => s.chatAttachmentRetryFailed,
  'chatUntitled' => s.chatUntitled,
  'chatStopResponse' => s.chatStopResponse,
  'chatSendMessage' => s.chatSendMessage,
  _ => throw ArgumentError(name),
};
