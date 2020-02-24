# JavaZone iOS

## Re-write 2020

This is the iOS application for JavaZone.

Changes from the previous version:

* Re-write using SwiftUI
* Targetting iPhone, iPad

Current state - see [issues list](https://github.com/javaBin/javazone-ios-app/issues)

Catalyst support to run on mac was something we wanted to add - but - until the libraries we are using also support it - the functionality would be severely restricted - so for now - we'v had to remove it.

--- 

## Libraries

Swift Package Manager seems to be working well enough that we are trying to avoid cocoapods or carthage if possible.

--- 

## Notes on SwiftUI

SwiftUI was released in 2019 as a new way to build the user interface in iOS applications. It can also be used on Mac 10.15 or later via Catalyst.

That being said - there are some things that are not yet available in SwiftUI. They either require a workaround (sometimes large) or are simply not possible yet. It is expected that at WWDC 2020 more of these functions will be added.

The biggest issue is no real support for setting a scroll point - so - opening at "now" or opening at "nearest to time of received notification" is currently not available.

For now - issues in the application due to this are [tagged SwiftUI](https://github.com/javaBin/javazone-ios-app/issues?q=is%3Aissue+is%3Aopen+label%3ASwiftIUI).

### Fastlane issues

Fastlane screenshot support requires a working UITest - which doesn't seem to work well with SwiftUI just yet. Things like the back button on NavigationView are ignored by the UITest system. So we will not be using fastlane for screenshots until this is better supported.

--- 

## Questions

* Why another re-write?
  * Because I want to learn SwiftUI - it really is as simple as that
* Why iOS 13 only?
  * Because that is the minimum requirement for SwiftUI apps: 
    * iOS 13, 
    * macOS 10.15, 
    * tvOS 13 and 
    * watchOS 6
