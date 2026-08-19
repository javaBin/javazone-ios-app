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

| Lane          | Command                                | Description                                       |
| ------------- | -------------------------------------- | ------------------------------------------------- |
| `unittest`    | `bundle exec fastlane ios unittest`    | Run unit tests                                    |
| `screenshots` | `bundle exec fastlane ios screenshots` | Regenerate App Store screenshots (3 simulators)   |
| `bump`        | `bundle exec fastlane ios bump`        | Increment the build number and commit it          |
| `bump_marketing` | `bundle exec fastlane ios bump_marketing` | Marketing version `year.x` -> `year.x+1`  |
| `new_conference_year` | `bundle exec fastlane ios new_conference_year year:2027` | Roll marketing over to `2027.1` |
| `tag_release` | `bundle exec fastlane ios tag_release` | Tag the shipped build and push                    |
| `gitprep`     | `bundle exec fastlane ios gitprep`     | `bump` + `tag_release`                            |
| `metadata`    | `bundle exec fastlane ios metadata`    | Push store metadata + screenshots, no binary      |
| `beta`        | `bundle exec fastlane ios beta`        | Test, bump, sign, build, upload to TestFlight     |
| `release`     | `bundle exec fastlane ios release`     | Test, bump, sign, build, upload to the App Store  |

`beta` and `release` run `unittest`, `bump` and `codesignprep` themselves, and only call
`tag_release` **after** a successful upload — a failed signing or upload should not leave a
tag behind for a build that never shipped.

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

### 4. Regenerate screenshots

```bash
bundle exec fastlane ios screenshots
```

Takes about 10 minutes across the three simulators in `fastlane/Snapfile`. Produces 11
files in `fastlane/screenshots/en-US/` — the iPad set has 3, not 4, because the UI test
deliberately skips `1_SessionList` there. The files are gitignored; they are regenerated,
never committed. Review them before going further.

### 5. Ship to TestFlight

```bash
bundle exec fastlane ios beta
```

Requires a clean working tree (`bump` starts with `ensure_git_status_clean`).
`upload_to_testflight` then waits for Apple to finish processing, typically 5–15 minutes —
it polls, so leave it running. The build goes to internal testers, no Beta App Review.

### 6. Push the store listing

```bash
bundle exec fastlane ios metadata
```

Uploads metadata and the new screenshots without a binary, so the App Store listing can be
reviewed in App Store Connect ahead of the release itself.

### 7. Release when the TestFlight build looks good

```bash
bundle exec fastlane ios release
```

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
