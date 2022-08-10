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

## Building etc

### Partner Logos

- Download new/updated SVGs from the javazone site.
- Open them in illustrator
- File > Export > Export for screens
- Formats: 1x, 2x and 3x with Suffixes "", "@2x", "@3x" and Format PNG

Add them to the Partners asset catalog (as Image Sets)

Update the partners.json file from src/pages/Partners/PartnerList.ts in the current javazone web project
