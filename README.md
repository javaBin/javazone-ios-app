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

### Fastlane issues

Fastlane screenshot support requires a working UITest - which doesn't seem to work well with SwiftUI just yet. Things like the back button on NavigationView are ignored by the UITest system. So we will not be using fastlane for screenshots until this is better supported.

---

### Fastlane submission

Set the following environment variables:

APPLE_ID=
SLACK_URL=
FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD=

Run `fastlane beta` to submit to app store for testing.

Run `fastlane releae` to submit to app store for publication.
