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
│   ├── Speaker.swift          # @Model
│   └── Config.swift           # AppConfig — @Observable, env-injected
├── Remote/                    # Decodable DTOs (RemoteSession, RemoteSpeaker, …)
├── Services/
│   ├── SessionService.swift   # Fetches + stores sessions; @MainActor
│   └── ConfigService.swift    # Fetches remote config
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
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Debug flags

| Flag                | Effect                                                                    |
| ------------------- | ------------------------------------------------------------------------- |
| `DEBUG`             | 25% chance of auto-refresh on launch (set automatically in Debug config)  |
| `TESTNOTIFICATIONS` | Notification fires 15 s after favouriting instead of 7 min before session |

---

## Testing

```bash
# Via Fastlane
bundle exec fastlane ios unittest

# Direct
xcodebuild test -project JavaZone.xcodeproj -scheme JavaZone \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

Tests live in `JavaZoneTests/` — `String+UtilsTest.swift` and `Date+UtilsTest.swift`.

---

## Deployment

Deployment is handled by **Fastlane**. Requires a `.env` file (not committed) with:

```
APPLE_ID=<your Apple ID>
FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD=<app-specific password from appleid.apple.com>
SLACK_URL=<webhook URL for the app Slack channel>
```

| Lane       | Command                             | Description                               |
| ---------- | ----------------------------------- | ----------------------------------------- |
| `unittest` | `bundle exec fastlane ios unittest` | Run unit tests                            |
| `gitprep`  | `bundle exec fastlane ios gitprep`  | Increment build number, commit, tag, push |
| `beta`     | `bundle exec fastlane ios beta`     | Sign, build, upload to TestFlight         |
| `release`  | `bundle exec fastlane ios release`  | Sign, build, upload to App Store          |

`beta` and `release` call `gitprep` and `codesignprep` automatically.

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
