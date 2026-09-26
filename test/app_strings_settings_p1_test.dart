import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/l10n/app_strings.dart';

/// Locks the P1 strings — the Settings surfaces beyond the appearance block.
///
/// The rule these assertions defend: [AppStringsEn] is byte-identical to the
/// literals that used to be hardcoded, so an English user sees no visual
/// change. If someone reworded a Settings label while adding a key, the
/// English expectation below fails.
///
/// The Chinese expectations are non-empty and use CJK, which is enough to
/// catch a missing translation without freezing the exact wording (that is
/// the translator's call, not the test's).
void main() {
  const en = AppStringsEn();
  const zh = AppStringsZh();

  group('English keeps the exact previous wording', () {
    test('profile default model', () {
      expect(en.settingsProfileDefaultModel, 'Profile default model');
      expect(
        en.settingsProfileDefaultModelDescription,
        'Changes the default for {0}. Use the selector in a chat to override '
        'only that conversation.',
      );
      expect(en.settingsCurrentProfileDefault, 'Current profile default');
      expect(en.settingsContextTokens, 'Context: {0} tokens');
      expect(en.settingsSetProfileDefault, 'Set profile default');
      expect(en.settingsProvider, 'Provider');
      expect(en.settingsModel, 'Model');
    });

    test('voice', () {
      expect(en.settingsVoice, 'Voice');
      expect(en.settingsVoiceAuto, 'Auto (device default)');
      expect(en.settingsVoiceNoneFound, contains('No TTS voices found'));
    });

    test('verbose mode', () {
      expect(en.settingsVerboseMode, 'Verbose Mode');
      expect(
        en.settingsVerboseModeDescription,
        'Show tool calls, thinking, and message metadata',
      );
    });

    test('about and section headers', () {
      expect(en.settingsAbout, 'About');
      expect(en.settingsAboutProduct, 'Hermes Agent for Android');
      expect(en.settingsVersion, 'Version {0}');
      expect(
        en.settingsAboutDescription,
        contains('Connects to a Hermes dashboard'),
      );
      expect(en.settingsSessionSources, 'Session Sources');
      expect(en.settingsConnection, 'Connection');
      expect(en.settingsBackupRestore, 'Backup & restore');
      expect(en.settingsLoadFailed, 'Failed to load settings');
      expect(en.commonRefresh, 'Refresh');
    });

    test('backup and restore', () {
      expect(en.backupTitle, 'Backup & restore');
      expect(en.backupExport, 'Export');
      expect(en.backupImport, 'Import');
      expect(en.backupProtectTitle, 'Protect this backup');
      expect(en.backupPassphrase, 'Passphrase');
      expect(en.backupConfirmPassphrase, 'Confirm passphrase');
      expect(en.backupRestoreTitle, 'Restore configuration');
      expect(en.backupMerge, 'Merge');
      expect(en.backupReplace, 'Replace');
      expect(en.backupRestore, 'Restore');
      expect(en.backupCancel, 'Cancel');
      expect(en.backupShowPassphrase, 'Show passphrase');
      expect(en.backupHidePassphrase, 'Hide passphrase');
    });
  });

  group('Chinese is translated, never a copy of English', () {
    test('every P1 key resolves to a distinct CJK string', () {
      final pairs = <String, List<String>>{
        'settingsProfileDefaultModel': [en.settingsProfileDefaultModel, zh.settingsProfileDefaultModel],
        'settingsProfileDefaultModelDescription': [
          en.settingsProfileDefaultModelDescription,
          zh.settingsProfileDefaultModelDescription,
        ],
        'settingsCurrentProfileDefault': [
          en.settingsCurrentProfileDefault,
          zh.settingsCurrentProfileDefault,
        ],
        'settingsContextTokens': [en.settingsContextTokens, zh.settingsContextTokens],
        'settingsSetProfileDefault': [en.settingsSetProfileDefault, zh.settingsSetProfileDefault],
        'settingsProvider': [en.settingsProvider, zh.settingsProvider],
        'settingsModel': [en.settingsModel, zh.settingsModel],
        'settingsVoice': [en.settingsVoice, zh.settingsVoice],
        'settingsVoiceAuto': [en.settingsVoiceAuto, zh.settingsVoiceAuto],
        'settingsVoiceNoneFound': [en.settingsVoiceNoneFound, zh.settingsVoiceNoneFound],
        'settingsVerboseMode': [en.settingsVerboseMode, zh.settingsVerboseMode],
        'settingsVerboseModeDescription': [
          en.settingsVerboseModeDescription,
          zh.settingsVerboseModeDescription,
        ],
        'settingsAbout': [en.settingsAbout, zh.settingsAbout],
        'settingsSessionSources': [en.settingsSessionSources, zh.settingsSessionSources],
        'settingsConnection': [en.settingsConnection, zh.settingsConnection],
        'settingsBackupRestore': [en.settingsBackupRestore, zh.settingsBackupRestore],
        'settingsLoadFailed': [en.settingsLoadFailed, zh.settingsLoadFailed],
        'commonRefresh': [en.commonRefresh, zh.commonRefresh],
        'backupTitle': [en.backupTitle, zh.backupTitle],
        'backupDescription': [en.backupDescription, zh.backupDescription],
        'backupExport': [en.backupExport, zh.backupExport],
        'backupImport': [en.backupImport, zh.backupImport],
        'backupProtectTitle': [en.backupProtectTitle, zh.backupProtectTitle],
        'backupProtectDescription': [
          en.backupProtectDescription,
          zh.backupProtectDescription,
        ],
        'backupPassphrase': [en.backupPassphrase, zh.backupPassphrase],
        'backupConfirmPassphrase': [
          en.backupConfirmPassphrase,
          zh.backupConfirmPassphrase,
        ],
        'backupRestoreTitle': [en.backupRestoreTitle, zh.backupRestoreTitle],
        'backupMerge': [en.backupMerge, zh.backupMerge],
        'backupMergeDescription': [en.backupMergeDescription, zh.backupMergeDescription],
        'backupReplace': [en.backupReplace, zh.backupReplace],
        'backupReplaceDescription': [
          en.backupReplaceDescription,
          zh.backupReplaceDescription,
        ],
        'backupRestore': [en.backupRestore, zh.backupRestore],
        'backupCancel': [en.backupCancel, zh.backupCancel],
        'backupShowPassphrase': [en.backupShowPassphrase, zh.backupShowPassphrase],
        'backupHidePassphrase': [en.backupHidePassphrase, zh.backupHidePassphrase],
      };

      for (final entry in pairs.entries) {
        final (e, z) = (entry.value[0], entry.value[1]);
        expect(z, isNotEmpty, reason: entry.key);
        expect(
          z.contains(RegExp(r'[\u4e00-\u9fff]')),
          isTrue,
          reason: '${entry.key} must contain CJK, got "$z"',
        );
      }
    });

    test('placeholders survive translation', () {
      // The model label and the context-token count are interpolated at the
      // call site; if a translation dropped {0} the user would see a raw
      // placeholder or a missing value.
      expect(en.settingsContextTokens, contains('{0}'));
      expect(zh.settingsContextTokens, contains('{0}'));
      expect(en.settingsProfileDefaultModelDescription, contains('{0}'));
      expect(zh.settingsProfileDefaultModelDescription, contains('{0}'));
      expect(en.settingsVersion, contains('{0}'));
      expect(zh.settingsVersion, contains('{0}'));
    });
  });
}
