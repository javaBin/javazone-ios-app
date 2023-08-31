# JavaZone iOS

## Re-write 2021

This is the iOS application for JavaZone.

Changes from the previous version:

- Re-write using SwiftUI
- Targetting iPhone, iPad

Current state - see [issues list](https://github.com/javaBin/javazone-ios-app/issues)

Catalyst support to run on mac was something we wanted to add - but - until the libraries we are using
also support it - the functionality would be severely restricted - so for now - we've had to remove it.

---

## Beta Testing

The current TestFlight signup link is https://testflight.apple.com/join/m56jE09M

---

## Libraries

This application uses SwiftPackageManager for its dependencies.

---

### Fastlane snapshots

Snapshots are created by `fastlane snapshot`.

Before running this command - run the app in each of the simulators named in [fastlane/Snapfile](fastlane/Snapfile) - and choose some favourites - otherwise the `My Schedule` view will be empty.

---

### Fastlane submission

Set the following environment variables:

```
APPLE_ID=<your apple id>
SLACK_URL=<URL for webhook to post to app channel on slack>
FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD=<App specific password for your user (can be generated on appleid.apple.com) - provisioning can use 2FA but upload cannot>
```

Update fastlane/metadata files to change links, texts etc.

Run `fastlane snapshot` to generate snapshots

Run `fastlane beta` to submit to app store for testing.

Run `fastlane release` to submit to app store for publication.
