# JavaZone iOS

iOS app for [JavaZone](https://javazone.no).

[![TestFlight](https://img.shields.io/badge/TestFlight-Join%20Beta-blue)](https://testflight.apple.com/join/m56jE09M)

---

## Features

- Browse and search the full session programme
- Filter sessions by day and keyword
- Build a personal schedule by favouriting sessions
- Receive a notification 7 minutes before a favourited session starts
- Read conference info, partner links, and app licences
- View session videos (Vimeo)

---

## Requirements

- iOS 26+
- Xcode 26+

---

## Architecture

SwiftUI + MVVM, targeting iOS 26. Key technology choices:

| Concern            | Solution                               |
| ------------------ | -------------------------------------- |
| Persistence        | SwiftData (`@Model`)                   |
| Networking         | `URLSession` async/await               |
| State / ViewModels | `@Observable` + `@MainActor`           |
| App entry point    | `@main JavaZoneApp: App`               |
| Notifications      | `UNUserNotificationCenter` async/await |

### Structure

```
JavaZone/
├── JavaZoneApp.swift          # @main entry point, ModelContainer, NotificationRouter
├── Data/
│   ├── Session.swift          # @Model
│   ├── SessionBody.swift      # @Model — abstract, audience, speakers
│   ├── Speaker.swift          # @Model
│   └── Config.swift           # AppConfig — @Observable, backed by UserDefaults
├── Remote/                    # Decodable DTOs (RemoteSession, RemoteSpeaker, …)
├── Services/
│   ├── SessionService.swift   # Fetches + stores sessions; @MainActor
│   ├── ConfigService.swift    # Fetches remote config
│   ├── NotificationScheduler.swift # Session reminders, rebuilt after each refresh
│   └── AvatarCache.swift      # Speaker avatar fetch + in-memory cache
├── Views/
│   ├── ContentView.swift      # TabView; Partners tab opens Safari directly
│   ├── Sessions/              # SessionsListView (@Query), detail, item views
│   ├── Info/                  # Info list, logs, licences
│   └── Components/            # DayPicker, SearchView, FavouriteToggleView, …
└── Extensions/                # Date+Utils, String+Utils, Log+Utils, …
```

### API endpoints

| Data      | URL                                                                 |
| --------- | ------------------------------------------------------------------- |
| Sessions  | `https://sleepingpill.javazone.no/public/allSessions/javazone_XXXX` |
| Config    | `https://sleepingpill.javazone.no/public/config`                    |
| Info JSON | `https://javabin.github.io/javazone-ios-app/info.json`              |

The `docs/` folder is the GitHub Pages source for `info.json`. See [`docs/README.md`](docs/README.md) for its schema.

---

## Build & Run

Open `JavaZone.xcodeproj` in Xcode and run, or from the command line:

```bash
xcodebuild -project JavaZone.xcodeproj -scheme JavaZone \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

### Debug flags

| Flag                | Effect                                                                    |
| ------------------- | ------------------------------------------------------------------------- |
| `DEBUG`             | Randomised auto-refresh on first appearance (set automatically in Debug)  |
| `TESTNOTIFICATIONS` | Notification fires 15 s after favouriting instead of 7 min before session |

---

## Testing

```bash
# Via Fastlane
bundle exec fastlane ios unittest

# Direct
xcodebuild test -project JavaZone.xcodeproj -scheme JavaZone \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

Tests live in `JavaZoneTests/`: the models (`SessionTests`, `SpeakerTests`,
`SessionBodyTests`), the extensions (`String+UtilsTest`, `Date+UtilsTest`), config
(`AppConfigTests`, `AppConfigPersistenceTests`), the store-writing half of the refresh
(`SessionServiceTests`) and reminder construction (`NotificationSchedulerTests`).

`JavaZoneUITests/` is the screenshot pipeline rather than a correctness suite — it drives
the app for Fastlane snapshot and lives in its own `JavaZoneUITests` scheme.

---

## Deployment

Deployment is handled by **Fastlane**. Requires a `.env` file (not committed) with:

```
APPLE_ID=<your Apple ID>
FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD=<app-specific password from appleid.apple.com>
SLACK_URL=<webhook URL for the app Slack channel>
```

It also expects the `xcbeautify` xcodebuild formatter:

```bash
brew install xcbeautify
```

No Fastlane configuration is needed — `gym` and `scan` default to `xcbeautify` whenever it is
on `PATH`, and fall back to the older `xcpretty` when it is not. The lanes still run without
it, but xcpretty parses xcodebuild output with regexes written against older Xcode releases
and can silently drop build errors.

| Lane          | Command                                | Description                                       |
| ------------- | -------------------------------------- | ------------------------------------------------- |
| `unittest`    | `bundle exec fastlane ios unittest`    | Run unit tests                                    |
| `screenshots` | `bundle exec fastlane ios screenshots` | Regenerate App Store screenshots (3 simulators)   |
| `bump`        | `bundle exec fastlane ios bump`        | Increment the build number and commit it          |
| `bump_marketing` | `bundle exec fastlane ios bump_marketing` | Marketing version `year.x` -> `year.x+1`  |
| `new_conference_year` | `bundle exec fastlane ios new_conference_year year:2027` | Roll marketing over to `2027.1` |
| `tag_release` | `bundle exec fastlane ios tag_release lane:iosbeta` | Tag the shipped build and push (see below) |
| `gitprep`     | `bundle exec fastlane ios gitprep lane:iosbeta`     | `bump` + `tag_release`                     |
| `metadata`    | `bundle exec fastlane ios metadata`    | Push store metadata + screenshots, no binary      |
| `beta`        | `bundle exec fastlane ios beta`        | Test, bump, sign, build, upload to TestFlight     |
| `release`     | `bundle exec fastlane ios release`     | Test, bump, sign, build, upload **and submit for review** |

`beta` and `release` run `unittest`, `bump` and `codesignprep` themselves, and only call
`tag_release` **after** a successful upload — a failed signing or upload should not leave a
tag behind for a build that never shipped.

`tag_release` names the tag `builds/<lane>/<build number>` and takes the build number from
`CURRENT_PROJECT_VERSION`. The lane part comes from `LANE_NAME`, which is the lane fastlane
was **invoked** with, not the one running — so inside `beta` and `release` it produces
`builds/iosbeta/N` and `builds/iosrelease/N` with no argument. Run on its own it would
produce `builds/iostag_release/N`, which is why the standalone commands above pass `lane:`.

---

## Versioning

| Number                  | Setting                    | Bumped                                    |
| ----------------------- | -------------------------- | ----------------------------------------- |
| Marketing (`year.x`)    | `MARKETING_VERSION`        | Once per App Store release                |
| Build (integer)         | `CURRENT_PROJECT_VERSION`  | Every push to TestFlight **or** App Store |

Both live in **project-level** build settings, so the app, the `Duke` sticker pack and the
test bundles all inherit one value — an app extension whose build number differs from the
containing app is rejected by App Store Connect. The `Info.plist` files only reference
them (`$(CURRENT_PROJECT_VERSION)` / `$(MARKETING_VERSION)`) and should never hold a
literal version.

> **Do not use `agvtool` on this project.** It writes literal versions into the
> `Info.plist` files, undoing that indirection, and `agvtool new-marketing-version` does
> not update `MARKETING_VERSION` at all — it only rewrites the plists, so the build setting
> and the shipped version silently diverge. `fastlane-plugin-versioning` is no good here
> either: it writes *target-level* settings, which leaves `Duke` behind on the old build
> number. The `bump` lanes edit the project-level build settings directly instead.

The build number bump happens inside `beta` and `release`. The marketing version is
deliberately **not** automatic, because the year rolls over by hand each conference:

```bash
bundle exec fastlane ios bump_marketing              # 2026.1 -> 2026.2
bundle exec fastlane ios new_conference_year year:2027   # -> 2027.1
```

---

## Annual release runbook

This happens roughly once a year, ahead of the conference. The order matters, and step 1
is the one that is easy to forget.

### 1. Wait for Sleeping Pill to serve the new year's config

Everything downstream depends on this. The app has no hardcoded year — the conference
name, the session-list URL and the three day labels all come from
`https://sleepingpill.javazone.no/public/config`, and the screenshots are generated by
driving the real app against whatever that endpoint returns.

Check it directly:

```bash
curl -s https://sleepingpill.javazone.no/public/config | jq
```

If `conferenceDates` still shows last year, **stop here**. Screenshots taken now would ship
last year's programme to the App Store.

### 2. Update the year-stamped content

| File                                      | What to change                                          |
| ----------------------------------------- | ------------------------------------------------------- |
| `fastlane/metadata/en-US/release_notes.txt` | Used as *both* App Store "What's New" and TestFlight "What to Test" |
| `fastlane/metadata/copyright.txt`         | `<year> javaBin`                                        |
| Marketing version                         | `bundle exec fastlane ios new_conference_year year:<year>` |
| `docs/info.json`                          | Wi-Fi SSID, food and AweZone links (see below)          |

`docs/info.json` is **not** part of the app release. It is served from GitHub Pages and the
Info tab picks it up within 5 minutes of the commit landing on `main` — for every user, on
every installed version. Treat committing it as an immediate deploy.

The year-stamped links follow a stable pattern (`https://<year>.javazone.no/en/food`,
`/en/awezone`), but those pages are published later than the config is. Confirm every link
resolves before committing, or users get a 404 from the Info tab:

```bash
jq -r '.[].url.url | select(.)' docs/info.json | while read -r u; do
  printf '%s -> ' "$u"; curl -s -o /dev/null -w '%{http_code}\n' -L --max-time 10 "$u"
done
```

The Wi-Fi SSID is not verifiable this way — check it against what the organisers publish.

### 3. Verify the app against the live config

```bash
bundle exec fastlane ios unittest
```

Then launch the app in a simulator: the day picker should show the new dates and the
session list should be populated. An empty programme here means the config or the session
feed is not ready.

A simulator that still holds **last year's** store will often show the old programme rather
than an empty one. The app only refreshes when its store is empty or on a randomised chance,
and `conferenceUrl` is re-read from the remote config only as part of a refresh — so stale
sessions and a stale conference URL go together. Pull to refresh, or erase the simulator,
before concluding the feed is broken.

### 4. Regenerate screenshots

```bash
bundle exec fastlane ios screenshots
```

Takes about four minutes across the three simulators in `fastlane/Snapfile`. Produces 11
files in `fastlane/screenshots/en-US/` — the iPad set has 3, not 4, because the UI test
deliberately skips `1_SessionList` there. The files are gitignored; they are regenerated,
never committed. Review them before going further.

The UI test launches with `--force-refresh`, a DEBUG-only flag, so the run always fetches the
live programme instead of whatever the simulators are still holding. Without it a simulator
carrying last year's data screenshots the wrong year while appearing to succeed. The test
then waits for the "Refreshing sessions" overlay to clear before touching any row, because a
refresh batch-deletes every session.

Expect rows 1, 3 and 5 of `1_SessionList` to show as already favourited on any run after the
first — the UI test favourites those, and favourites now survive between runs. That is
accepted and ships as-is.

### 5. Ship to TestFlight

```bash
bundle exec fastlane ios beta
```

Requires a clean working tree (`bump` starts with `ensure_git_status_clean`).
`upload_to_testflight` then waits for Apple to finish processing, typically 5–15 minutes —
it polls, so leave it running. The build goes to internal testers, no Beta App Review.

If the lane fails *after* the upload succeeds — tagging is the last thing it does — do **not**
re-run `beta`, which would bump and upload a second build. Tag the one that shipped instead:

```bash
bundle exec fastlane ios tag_release lane:iosbeta
```

Distributing to **external** testers is a separate, manual step in App Store Connect and does
require Beta App Review. Start it as early as you can, since it runs in parallel with
everything else.

### 6. Push the store listing

```bash
bundle exec fastlane ios metadata
```

Uploads metadata and the new screenshots without a binary, so the App Store listing can be
reviewed in App Store Connect ahead of the release itself.

Nothing needs creating by hand in App Store Connect first. The lane passes
`app_version: MARKETING_VERSION`, which is what makes `deliver` create the editable version
if there isn't one — it only does that when it is told which version to create, and with no
binary to upload it has nothing to infer that from. It is also the reason the number comes
from the project rather than from `deliver`'s own default, which globs `*.ipa` in the working
directory: a stale `JavaZone.ipa` left behind by an earlier `build_app` would otherwise decide
the version, and an editable version under a different number gets *renamed* to match.

### 7. Release when the TestFlight build looks good

```bash
bundle exec fastlane ios release
```

This submits for review as well as uploading — `deliver` waits for the build to finish
processing, attaches it to the version and creates the review submission, so there is no
"pick the build and press Submit" step in App Store Connect. Export compliance is answered
ahead of time by `ITSAppUsesNonExemptEncryption` in `JavaZone/Info.plist`; remove that key and
the lane will stop and ask for `submission_information` instead.

Approval does **not** publish. `automatic_release: false` leaves the version Pending Developer
Release, so the App Store update is timed by pressing Release in App Store Connect rather than
by Apple's review queue.

Re-running `release` after a failure part-way through fails with *"A review submission is
already in progress"* if the submission was created before the failure. Cancel the submission
in App Store Connect first, or — if the upload itself succeeded — just tag the shipped build
(`bundle exec fastlane ios tag_release lane:iosrelease`) and submit from the web UI.

---

## Sticker pack icons

The `Duke` sticker pack's icon set — 13 PNGs in
`Duke/Stickers.xcassets/iMessage App Icon.stickersiconset` — is generated from the app icon,
`JavaZone/Assets.xcassets/AppIcon.appiconset/ios-marketing.png`. Regenerate it whenever the
app icon changes; it does not follow automatically.

> Every file in that set must be **fully opaque**. App Store Connect rejects any alpha
> channel in an iMessage app icon with error 90647, and the rejection arrives at *upload*
> time — after a successful build, archive and export. This has regressed once already, when
> a sticker pack was re-added from a commit that predated the original fix.

Verify the **compiled** icons rather than the sources: `actool` extracts them as loose PNGs
into the appex root, and those are what Apple inspects.

```bash
sips -g hasAlpha "$(find ~/Library/Developer/Xcode/DerivedData -name 'JavaZone.appex' | head -1)/iMessage App Icon27x20@2x.png"
# must report: hasAlpha: no
```

Eight of the thirteen are 4:3 rather than square. Crop the square app icon to each target's
exact ratio rather than letterboxing it — take the crop off the empty space above the artwork
first and the remainder off the bottom. Letterboxing leaves Duke too small to read at 54x40.

---

## Configuration

`JavaZone/EnvConfig.xcconfig` is read at build time and injects values into `Info.plist`:

```
PARTNER_URL = javazone.no/partner
```

`AppConfig` (persisted in `UserDefaults`) is seeded from the remote config endpoint on first launch and updated on each session refresh.

---

## Contributing

Issues and pull requests welcome. Current known issues: [GitHub Issues](https://github.com/javaBin/javazone-ios-app/issues).
