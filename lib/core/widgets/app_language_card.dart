import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_strings.dart';
import '../services/app_language.dart';

/// App-wide interface-language control. It stores only the selected language;
/// connection, profile, and credential data never enter this namespace.
///
/// Structurally a sibling of `TextSizeSettingsCard`: a card row that opens a
/// bottom sheet with a radio group. Language and text size are the same kind
/// of choice, so they look the same and behave the same.
class AppLanguageCard extends StatefulWidget {
  const AppLanguageCard({
    required this.preferences,
    required this.onChanged,
    super.key,
  });

  final SharedPreferences preferences;
  final ValueChanged<AppLanguage> onChanged;

  @override
  State<AppLanguageCard> createState() => _AppLanguageCardState();
}

class _AppLanguageCardState extends State<AppLanguageCard> {
  late final AppLanguageStore _store;
  late AppLanguage _language;

  @override
  void initState() {
    super.initState();
    _store = AppLanguageStore(widget.preferences);
    _language = _store.read();
  }

  Future<void> _select(AppLanguage language) async {
    if (language == _language) {
      Navigator.of(context).pop();
      return;
    }
    await _store.save(language);
    if (!mounted) return;
    setState(() => _language = language);
    widget.onChanged(language);
    if (mounted) Navigator.of(context).pop();
  }

  /// The user-facing name of one choice.
  ///
  /// Language names are endonyms: `English` and `简体中文` are rendered in
  /// their own script whatever the current interface language, so a user can
  /// always find their language without reading a foreign label first.
  String _labelFor(AppLanguage language, AppStrings strings) {
    return language == AppLanguage.chinese
        ? strings.languageChinese
        : strings.languageEnglish;
  }

  Future<void> _showPicker() {
    final strings = AppStrings.of(context);
    String subtitleFor(AppLanguage language) => language.followsSystem
        ? strings.languageSubtitleSystem
        : strings.languageSubtitleExplicit;

    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.language,
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(strings.languageSheetDescription),
                const SizedBox(height: 8),
                RadioGroup<AppLanguage>(
                  groupValue: _language,
                  onChanged: (value) {
                    if (value != null) _select(value);
                  },
                  child: Column(
                    children: [
                      for (final language in AppLanguage.values)
                        RadioListTile<AppLanguage>(
                          value: language,
                          title: Text(_labelFor(language, strings)),
                          subtitle: Text(subtitleFor(language)),
                          contentPadding: EdgeInsets.zero,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final selected = _language.followsSystem
        ? strings.themeSystem
        : _labelFor(_language, strings);
    final subtitle = _language.followsSystem
        ? strings.languageSubtitleSystem
        : strings.languageSubtitleExplicit;
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: '${strings.language}: $selected',
            button: true,
            child: ExcludeSemantics(
              child: ListTile(
                leading: const Icon(Icons.translate, size: 20),
                title: Text(strings.language),
                subtitle: Text(
                  '$selected — $subtitle',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showPicker,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
