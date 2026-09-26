# P1 batch 3 — Projects scope notes

Follows `docs/i18n-scope-decision.md` (P0/P1 总纲), `docs/i18n-glossary.md`
(术语表), `docs/i18n-chats-batch.md` (batch 2). This note records only the
decisions specific to `projects_pane.dart` and `project_detail_screen.dart`.

## What was translated

Everything the user reads on both screens: section headers, chips, action
menus, every empty / error / offline / unsupported state, the create and
rename dialogs, the archive and delete confirmations, the move sheet, the
search field, and the five detail tabs (会话 / 概览 / 文件 / 资源 / 动态).

Keys use the `projects*` and `projectDetail*` prefixes. 209 keys total across
the P0 + P1 sets, with every English value byte-identical to the literal it
replaced; `test/app_strings_projects_p1_test.dart` (14 tests) asserts that
from both sides.

## Interpolated verbs, not English literals in a Chinese sentence

Two snackbar templates interpolate a **verb**: `Could not {0} the project: {1}`
and `Couldn’t {0} project`. The call sites pass internal identifiers
(`'create'`, `'rename'`, `'archive'`, `'restore'`, `'delete'`). Left as-is,
a Chinese user would read `无法 archive 项目`.

So the verbs are now mapped through `projectsActionCreate` /
`projectsActionRename` / `projectsActionArchive` / `projectsActionRestore`
(with `projectDetailDeleteProject` for delete) before substitution. Both
`projectsMutationFailed` and `projectDetailManageFailed` then render fully
localised text. The tests assert the mapping exists in both languages.

## Plurals

The local-space card shows `1 chat` versus `N chats`. Without
`intl`/gen-l10n (which would force a `pubspec.yaml` change and trip the
versionCode gate) a plural category cannot be selected automatically, so this
uses two explicit keys — `projectsOneChat` and `projectsChatCount` — chosen by
a `sessionCount == 1` check in the widget. Chinese has no plural agreement
(`1 个会话` / `N 个会话`), so both keys are still needed for readability of the
quantifier.

## Numbers are not translated

`'${repo.sessionCount}'` in `_RepoCard` renders as a bare number and is left
alone: a numeral looks identical in both languages, so wrapping it would add a
key with no behavioural difference.

## Project names are data

Project names, repository labels, folder paths and descriptions come from the
Gateway. They are never translated — only the chrome around them is. Delete and
archive confirmations interpolate the name with `{0}`, wrapped in 「」 in
Chinese, so the boundary between the app's words and the user's data stays
visible.

## Verification

`flutter analyze --no-pub --fatal-infos` → no issues; the whole suite
(`scripts/test-sharded.sh`, 84 files, sequential) → 84/84; the English values
are locked by `test/app_strings_projects_p1_test.dart` (14 tests).
`pubspec.yaml` / `pubspec.lock` unchanged.
