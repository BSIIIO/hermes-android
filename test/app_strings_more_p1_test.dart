import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/l10n/app_strings.dart';

/// Locks the P1 batch-4 strings — Files, Skills, Memory and Cron.
///
/// The invariant from the earlier batches still holds: [AppStringsEn] is
/// byte-identical to the literals it replaced, so an English user sees no
/// visual change; the Chinese values are non-empty and contain CJK.
void main() {
  const en = AppStringsEn();
  const zh = AppStringsZh();

  group('English keeps the exact previous wording', () {
    test('files screen', () {
      expect(en.filesTitle, 'Files');
      expect(en.filesEmptyTitle, 'Folder is empty');
      expect(
        en.filesEmptyMessage,
        'There are no visible files in this server folder.',
      );
      expect(en.filesPreviewTruncated, 'Preview truncated');
      expect(en.filesPreviewUnavailable, 'Preview unavailable');
      expect(
        en.filesBinaryPreviewUnavailable,
        'Binary preview is unavailable. Download the file to open it.',
      );
      expect(en.filesDownload, 'Download');
      expect(en.filesDownloaded, '{0} downloaded');
      expect(en.filesDownloadFailed, 'Download failed: {0}');
      expect(en.filesAddedToChat, 'File reference added to chat');
      expect(en.filesAddToChat, 'Add to chat');
      expect(en.filesLoadFailedTitle, 'Could not load files');
      expect(en.filesPreviewFailedTitle, 'Could not preview file');
      expect(
        en.filesErrorMessage,
        'Check the Dashboard connection and try again.',
      );
      expect(en.filesSaveDialogTitle, 'Save {0}');
    });

    test('skills screen', () {
      expect(en.skillsTitle, 'Skills ({0})');
      expect(en.skillsLoadFailed, 'Failed to load skills');
      expect(en.skillsEmptyTitle, 'No skills found');
      expect(
        en.skillsEmptyMessage,
        'Skills are reusable agent instructions published by the Hermes host.',
      );
    });

    test('memory screen', () {
      expect(en.memoryTitle, 'Memory');
      expect(en.memorySource, 'Source: {0}');
      expect(en.memoryLoadFailed, 'Failed to load memory');
      expect(en.memoryEmptyTitle, 'No memory entries');
      expect(
        en.memoryEmptyMessage,
        'Memory entries are cross-session facts the agent remembers.\n'
        'They are stored on the Hermes host and shared across your devices.',
      );
    });

    test('cron screen: chrome and states', () {
      expect(en.cronTitle, 'Cron Jobs');
      expect(en.cronAddJob, 'Add Cron Job');
      expect(en.cronEditJob, 'Edit Cron Job');
      expect(en.cronAddNewJob, 'Add new cron job');
      expect(en.cronAddAction, 'Add');
      expect(en.cronSaveAction, 'Save');
      expect(en.cronLoadFailed, 'Failed to load cron jobs');
      expect(en.cronOperationFailed, 'Failed: {0}');
      expect(en.cronEmptyTitle, 'No cron jobs');
      expect(
        en.cronEmptyMessage,
        'Scheduled jobs run agent turns on the Hermes host on your behalf.',
      );
    });

    test('cron screen: job editor', () {
      expect(en.cronNameLabel, 'Name');
      expect(en.cronNameHint, 'e.g., Daily backup');
      expect(en.cronPromptLabel, 'Prompt');
      expect(en.cronPromptHint, 'What should the agent do?');
      expect(en.cronScheduleLabel, 'Schedule');
      expect(en.cronScheduleHint, 'e.g., 0 9 * * * or every 2h');
      expect(en.cronScriptOnly, 'Script only (no agent)');
      expect(en.cronScriptOnlyHint, 'Use for cron jobs backed by scripts.');
      expect(en.cronScriptBadge, 'script');
      expect(en.cronFieldsRequired, 'Name, prompt, and schedule are required');
    });

    test('cron screen: actions and row', () {
      expect(en.cronTriggerNow, 'Trigger now');
      expect(en.cronEdit, 'Edit');
      expect(en.cronDelete, 'Delete');
      expect(en.cronPause, 'Pause');
      expect(en.cronResume, 'Resume');
      expect(en.cronJobAdded, 'Cron job added');
      expect(en.cronJobUpdated, 'Cron job updated');
      expect(en.cronJobDeleted, 'Deleted “{0}”');
      expect(en.cronJobTriggered, 'Job triggered');
      expect(en.cronJobPaused, 'Job paused');
      expect(en.cronJobResumed, 'Job resumed');
      expect(en.cronDeleteConfirmTitle, 'Delete “{0}”?');
      expect(en.cronDeleteConfirmBody, 'Delete “{0}”?');
      expect(en.cronLastRun, 'Last: {0}');
      expect(en.cronNextRun, 'Next: {0}');
    });
  });

  group('Chinese is present and uses CJK', () {
    test('every batch-4 string translates', () {
      final values = <String>[
        zh.filesTitle,
        zh.filesEmptyTitle,
        zh.filesEmptyMessage,
        zh.filesPreviewTruncated,
        zh.filesPreviewUnavailable,
        zh.filesBinaryPreviewUnavailable,
        zh.filesDownload,
        zh.filesDownloaded,
        zh.filesDownloadFailed,
        zh.filesAddedToChat,
        zh.filesAddToChat,
        zh.filesLoadFailedTitle,
        zh.filesPreviewFailedTitle,
        zh.filesErrorMessage,
        zh.filesSaveDialogTitle,
        zh.skillsTitle,
        zh.skillsLoadFailed,
        zh.skillsEmptyTitle,
        zh.skillsEmptyMessage,
        zh.memoryTitle,
        zh.memorySource,
        zh.memoryLoadFailed,
        zh.memoryEmptyTitle,
        zh.memoryEmptyMessage,
        zh.cronTitle,
        zh.cronAddJob,
        zh.cronEditJob,
        zh.cronNameLabel,
        zh.cronNameHint,
        zh.cronPromptLabel,
        zh.cronPromptHint,
        zh.cronScheduleLabel,
        zh.cronScheduleHint,
        zh.cronAddNewJob,
        zh.cronScriptOnly,
        zh.cronScriptOnlyHint,
        zh.cronScriptBadge,
        zh.cronFieldsRequired,
        zh.cronJobAdded,
        zh.cronJobUpdated,
        zh.cronJobDeleted,
        zh.cronJobTriggered,
        zh.cronJobPaused,
        zh.cronJobResumed,
        zh.cronTriggerNow,
        zh.cronEdit,
        zh.cronDelete,
        zh.cronPause,
        zh.cronResume,
        zh.cronAddAction,
        zh.cronSaveAction,
        zh.cronDeleteConfirmTitle,
        zh.cronDeleteConfirmBody,
        zh.cronLastRun,
        zh.cronNextRun,
        zh.cronOperationFailed,
        zh.cronLoadFailed,
        zh.cronEmptyTitle,
        zh.cronEmptyMessage,
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
    test('every {0} template substitutes in both languages', () {
      for (final strings in const <AppStrings>[
        AppStringsEn(),
        AppStringsZh(),
      ]) {
        expect(strings.filesDownloaded.contains('{0}'), true);
        expect(strings.filesDownloadFailed.contains('{0}'), true);
        expect(strings.filesSaveDialogTitle.contains('{0}'), true);
        expect(strings.skillsTitle.contains('{0}'), true);
        expect(strings.memorySource.contains('{0}'), true);
        expect(strings.cronJobDeleted.contains('{0}'), true);
        expect(strings.cronDeleteConfirmTitle.contains('{0}'), true);
        expect(strings.cronDeleteConfirmBody.contains('{0}'), true);
        expect(strings.cronLastRun.contains('{0}'), true);
        expect(strings.cronNextRun.contains('{0}'), true);
        expect(strings.cronOperationFailed.contains('{0}'), true);
      }
    });

    test('substituting a real value works', () {
      expect(
        zh.filesDownloaded.replaceAll('{0}', 'notes.md'),
        contains('notes.md'),
      );
      expect(
        zh.filesDownloadFailed.replaceAll('{0}', 'boom'),
        contains('boom'),
      );
      expect(
        zh.filesSaveDialogTitle.replaceAll('{0}', 'notes.md'),
        contains('notes.md'),
      );
      expect(zh.skillsTitle.replaceAll('{0}', '7'), contains('7'));
      expect(
        zh.memorySource.replaceAll('{0}', 'config'),
        contains('config'),
      );
      expect(
        zh.cronJobDeleted.replaceAll('{0}', 'Daily backup'),
        contains('Daily backup'),
      );
      expect(
        zh.cronLastRun.replaceAll('{0}', '09:00'),
        contains('09:00'),
      );
      expect(
        zh.cronOperationFailed.replaceAll('{0}', 'boom'),
        contains('boom'),
      );
    });
  });
}
