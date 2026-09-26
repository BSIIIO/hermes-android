# i18n batch 6 — phone-tested gaps + a layout regression

Everything in this batch was found by **installing a signed release build on a
real phone**, not by reading code. That distinction matters: the four gaps below
are places where a literal looks like it is covered by a scan but is not, and the
fifth is a bug only a human eye catches.

## 1. Text size options (enum, not widget)

`TextSizePreference` carried its own English display vocabulary:

```dart
system('system', 'System', 1.0),
extraLarge('extra_large', 'Extra large', 1.30),
...
String get description => followsSystemExactly
    ? 'Use Android accessibility text size exactly.'
    : '${(multiplier * 100).round()}% of the Android text size.';
```

A scan for `Text('...')` never finds these, because they are enum fields
interpolated elsewhere — the picker literally rendered `Extra large` in a
Chinese UI.

`label` and `description` became `label(AppStrings)` / `description(AppStrings)`
resolving through a `switch`. **`storageValue` is deliberately unchanged**: it is
the persisted key in `SharedPreferences`, and renaming it would silently reset
every user's saved choice back to System.

## 2. `lib/main.dart` connection editor

The whole proxy/dashboard form — expander title, both dialogs, path prefixes,
dashboard-behind-proxy, port notes, Desktop Gateway URL, Hermes profile. It was
the one large surface still entirely in English. 25 keys.

Subtlety: the two dialogs' copy is *similar but not identical*
(`'e.g. /dashboard'` vs `'e.g. /dashboard (proxy path before /api/)'`), so they
get separate keys rather than one shared string being stretched.

## 3. More pane

`buildMoreSections()` is a **top-level function returning plain data classes**
(`MoreSection` / `MoreEntry` hold raw `String title` / `subtitle`), with no
`BuildContext` anywhere — so there was nothing to call `AppStrings.of` on.

Fixed by threading `required AppStrings s` through the function, the same shape
used for the top-level `showSessionNameDialog` in batch 2. The four
`unavailableReason` constants became reads from `s`, and two `const MoreEntry`
constructors lost their `const` (their fields are now runtime values).

## 4. Activity pane

Overflow note (`'and $count more'`) and the offline banner. Plus the error
title, whose body text was long enough to need its own key.

## 5. The layout bug: `跟随系统` wrapped

**Symptom:** in 简体中文 at System text size, the theme picker's first segment
rendered `统` on a second line.

**Cause is structural, not cosmetic.** `SegmentedButton` sizes each segment from
Material's **English** text metrics, because this app intentionally never sets
`supportedLocales` — a zh `MaterialLocalizations` delegate would be required and
`flutter_localizations` is not a dependency, so the built-in delegate drops
`MaterialLocalizations` entirely and every `AppBar` throws
`No MaterialLocalizations found` (documented in `docs/i18n-scope-decision.md`).
`跟随系统` is 4 full-width glyphs where `System` is 6 half-width letters, and the
18dp icon plus its 8dp gap push the measured width past the segment.

**Fix:** `maxLines: 1` + `overflow: ellipsis` on each label, the theme's
`labelMedium` text style so the measurement uses the real style rather than an
implicit default, and a `tooltip` equal to the label so an ellipsized string is
still readable on long-press.

**How it is tested:** `_ThemeToggle` was a private class inside
`settings_screen.dart`, so it could not be pumped from a test. Rather than write
a *copy* that could silently drift from the real widget, it was extracted to a
public `ThemeModeCard` in `lib/core/widgets/`. The test now exercises the real
widget.

Two things worth knowing if you touch that test:

- `ButtonSegment` is **not** a `Widget` — it is a config object. `widgetList<ButtonSegment<...>>` does not compile, and `find.byType(ButtonSegment)` never matches. Read the segments off `tester.widget<SegmentedButton<String>>(...)`.
- `AppStrings.of(context)` falls back to `AppStringsEn` when no `AppStringsScope`
  is installed. A bare `MaterialApp` test therefore renders English, not
  Chinese. The test asserts that fallback explicitly (it is deliberate: English
  beats a crash) and then re-pumps under a real `AppStringsScope` to assert the
  zh labels.

## Verify

- `flutter analyze --no-pub --fatal-infos` — no issues
- `more_pane_test` 18/18, `activity_pane_test` 13/13, `text_size_preference_test` 6/6, `theme_picker_wrap_test` 3/3
- `pubspec.yaml` / `pubspec.lock` — zero diff

## Not touched

The remaining `lib/main.dart` literals are the API-key / endpoint hints
(`192.168.1.50, 100.x.y.z`, `8642 (API Server)`,
`API_SERVER_KEY from ~/.hermes/.env`) and the `HERMES` wordmark. They are
technical values rather than prose, and the user confirmed these are
intentionally left in English.
