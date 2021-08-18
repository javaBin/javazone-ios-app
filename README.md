# JavaZone iOS

## Re-write 2021

This is the iOS application for JavaZone.

Changes from the previous version:

* Re-write using SwiftUI
* Targetting iPhone, iPad

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

## Notes on SwiftUI

SwiftUI was released in 2019 as a new way to build the user interface in iOS applications. It can also be used on Mac 10.15 or later via Catalyst.

That being said - there are some things that are not yet available in SwiftUI. They either require a workaround (sometimes large) or are simply not possible yet. It is expected that more of these functions will be added over time.

For now - issues in the application due to this are [tagged SwiftUI](https://github.com/javaBin/javazone-ios-app/issues?q=is%3Aissue+is%3Aopen+label%3ASwiftIUI).

### Fastlane issues

Fastlane screenshot support requires a working UITest - which doesn't seem to work well with SwiftUI just yet. Things like the back button on NavigationView are ignored by the UITest system. So we will not be using fastlane for screenshots until this is better supported.

--- 

## Questions

* Why another re-write?
  * Because I want to learn SwiftUI - it really is as simple as that
* Why only the latest iOS?
  * Because I don't have time do work on multi-version support
