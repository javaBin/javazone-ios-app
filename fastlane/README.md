fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios unittest

```sh
[bundle exec] fastlane ios unittest
```

Unit Tests

### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

Generate screenshots

### ios bump

```sh
[bundle exec] fastlane ios bump
```

Bump the build number and commit it

### ios bump_marketing

```sh
[bundle exec] fastlane ios bump_marketing
```

Bump the marketing version (year.x -> year.x+1)

### ios new_conference_year

```sh
[bundle exec] fastlane ios new_conference_year
```

Roll the marketing version over to a new conference year (e.g. 2027.1)

### ios tag_release

```sh
[bundle exec] fastlane ios tag_release
```

Tag the shipped build and push

### ios gitprep

```sh
[bundle exec] fastlane ios gitprep
```

Git preparation (bump, tag and push in one go)

### ios codesignprep

```sh
[bundle exec] fastlane ios codesignprep
```

Auto code sign

### ios metadata

```sh
[bundle exec] fastlane ios metadata
```

Push store metadata and screenshots to App Store Connect (no binary)

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Push a new beta build to TestFlight

### ios release

```sh
[bundle exec] fastlane ios release
```

Push a new build to the App Store

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
