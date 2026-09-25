import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide interface-language choice, stored independently of profiles.
///
/// Mirrors the shape of [TextSizePreference]: a storage value, an explicit
/// "follow the system" case, and a lookup that falls back to [system] for
/// unknown stored values. Only a display preference lives in this namespace —
/// connection, profile, and credential data never enter it.
///
/// Storage values use ISO 639-1 language codes (`en`, `zh`) so a future third
/// language slots in without migrating stored data.
enum AppLanguage {
  /// Follow the Android system language exactly.
  system('system'),

  /// English interface.
  english('en'),

  /// Simplified Chinese interface.
  chinese('zh');

  const AppLanguage(this.storageValue);

  /// Storage key shared with the rest of the app-wide display preferences
  /// (`theme_mode`, `app_text_size_preference`).
  static const preferenceKey = 'app_language_preference';

  /// The value persisted in [SharedPreferences].
  final String storageValue;

  /// True when this choice defers to the Android system language.
  bool get followsSystem => this == AppLanguage.system;

  /// The [Locale] the app should materialise for this choice.
  ///
  /// [system] returns null so `MaterialApp.locale` keeps deferring to
  /// `platformDispatcher.locale`, which is more robust across Android
  /// per-app language, split-screen, and locale changes at runtime than
  /// resolving the language code by hand.
  Locale? get locale => switch (this) {
    AppLanguage.system => null,
    AppLanguage.english => const Locale('en'),
    AppLanguage.chinese => const Locale('zh'),
  };

  static AppLanguage fromStorage(String? value) {
    return AppLanguage.values.firstWhere(
      (language) => language.storageValue == value,
      orElse: () => AppLanguage.system,
    );
  }
}

/// Reads and writes the app-wide interface language.
///
/// Deliberately mirrors [TextSizePreferenceStore]: a thin wrapper over
/// [SharedPreferences] with no caching of its own, so a language switch made
/// anywhere in the app is visible to the next reader.
class AppLanguageStore {
  AppLanguageStore(this._preferences);

  final SharedPreferences _preferences;

  AppLanguage read() {
    return AppLanguage.fromStorage(
      _preferences.getString(AppLanguage.preferenceKey),
    );
  }

  Future<void> save(AppLanguage language) {
    return _preferences.setString(AppLanguage.preferenceKey, language.storageValue);
  }
}
