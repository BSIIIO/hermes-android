# Release signing — how to set up RELEASE_KEYSTORE (path C)

This build is an **independent distribution**: `applicationId` is
`com.hermesagent.hermes_android.zh`, not the upstream
`com.hermesagent.hermes_android`. Android treats a different applicationId as a
**different app**, so:

- old upstream installs keep working and stay untouched,
- this build can be installed **alongside** them,
- upgrades between the two are impossible by design — that is the accepted
  trade-off here, because the upstream release keystore is private and a fresh
  keystore signed against the old ID would break every existing install.

Because of that, the keystore pinned in `.github/workflows/release.yml` must be
**yours**, not the upstream SHA-256 (`475baf43…`) that used to sit there.

---

## 1. Generate the keystore (once, keep it forever)

`keytool` ships with a JDK. On this NAS there is no JDK — install one, or run
this on your Windows laptop (JDK 17 / Android Studio bundles it).

```bash
keytool -genkeypair -v -keystore release.keystore \
  -alias hermes \
  -keyalg RSA -keysize 4096 -validity 10000 \
  -dname "CN=Hermes Agent, O=personal, C=CN"
```

You will be prompted for two passwords:

- **store password** → GitHub secret `STORE_PASSWORD`
- **key password** → GitHub secret `KEY_PASSWORD` (may be identical)
- **alias** → `KEY_ALIAS`, here `hermes`

> **Back up `release.keystore` and both passwords now.** Lose them and you can
> never ship an update to anyone who installed a build you signed. A copy in a
> password manager plus one offline copy is the usual minimum. If the file ever
> has to be rebuilt, users must uninstall and reinstall.

## 2. Read the certificate fingerprint

```bash
keytool -list -v -keystore release.keystore -alias hermes | grep 'SHA256:'
```

Example output:

```
         SHA256: AB:CD:EF:12:34:...
```

Strip the colons and lowercase it — that value goes into
`.github/workflows/release.yml`:

```yaml
EXPECTED_RELEASE_CERT_SHA256: 'abcdef1234...'
```

> Why this line exists: it fails the build if a *different but also valid*
> keystore is used, so an accidental key swap cannot silently break in-place
> upgrades. With it left empty the release job now fails fast with an explicit
> explanation instead of a confusing `signer mismatch`.

## 3. Add the four repository secrets

GitHub **blocks** a secret from being used as the default value of an `env:` in a
workflow, which is why the certificate digest lives in the workflow file and only
these four live in Secrets:

| Secret | Value |
|---|---|
| `KEYSTORE_BASE64` | `base64 -w0 release.keystore` (single line, no newlines) |
| `STORE_PASSWORD` | store password |
| `KEY_PASSWORD` | key password |
| `KEY_ALIAS` | `hermes` |

CLI, if you prefer it over the web UI (needs `gh auth login` first):

```bash
gh secret set KEYSTORE_BASE64 < <(base64 -w0 release.keystore)
gh secret set STORE_PASSWORD
gh secret set KEY_PASSWORD
gh secret set KEY_ALIAS --body hermes
```

Or the web UI: **Settings → Secrets and variables → Actions → New repository
secret**.

Never commit `release.keystore`, `key.properties`, or the base64 blob. The repo
already ignores `key.properties`; `release.keystore` must never be added.

## 4. Ship a release

```bash
# pubspec.yaml version drives the tag; CI refuses a tag that does not match
# version: 2.1.3+2143  ->  tag v2.1.3
git tag -a v2.1.4 -m "Hermes Android v2.1.4"
git push origin v2.1.4
```

The `Release` workflow then: verifies the versionCode, refuses an unsigned
**tagged** release, signs with your secrets, checks the APK against the pinned
SHA-256, and creates the GitHub Release with the signed per-ABI APKs attached.

An untagged `workflow_dispatch` run still works without any secret — it builds a
**debug** validation artifact, which is useful to confirm the toolchain before
you commit to signing.

---

## Quick reference — what changed for path C

| File | Change |
|---|---|
| `android/app/build.gradle.kts` | `namespace` + `applicationId` → `…hermes_android.zh` |
| `android/app/build.gradle.kts` | debug `applicationIdSuffix = ".dev"` now yields `…zh.dev` |
| `AndroidManifest.xml`, `shortcuts.xml` | quick-chat action renamed to the new IDs |
| `MainActivity.kt` | package + the launch/share MethodChannel + quick-chat constant |
| `lib/core/services/android_*_intent_service.dart` | channel names must match the Kotlin side, or the bridge dies at runtime |
| `test/android_launcher_shortcut_contract_test.dart` | asserts the new action string |
| `README.md`, `CHANGELOG.md` | package IDs documented |
| `.github/workflows/release.yml` | pinned cert cleared + fail-fast guard with the reason |

The MethodChannel names are the part people forget: they are plain strings with
no compile-time link between Dart and Kotlin, so a mismatch compiles clean and
then throws `MissingPluginException` the first time you share something to the
app. They are renamed in lockstep above.
