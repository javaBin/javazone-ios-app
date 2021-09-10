// This file contains the fastlane.tools configuration
// You can find the documentation at https://docs.fastlane.tools
//
// For a list of all available actions, check out
//
//     https://docs.fastlane.tools/actions
//

import Foundation

class Fastfile: LaneFile {
	func betaLane() {
	desc("Push a new beta build to TestFlight")
		ensureGitStatusClean()
		incrementBuildNumber(xcodeproj: "JavaZone.xcodeproj")
		commitVersionBump(xcodeproj: "JavaZone.xcodeproj")
		addGitTag()
		pushToGitRemote()
		getProvisioningProfile(appIdentifier: "net.chrissearle.incogito.JavaZone")
		getProvisioningProfile(appIdentifier: "net.chrissearle.incogito.JavaZone.Duke")
		buildApp(scheme: "JavaZone")
		uploadToTestflight()
		slack(message: "Beta build uploaded")
	}
}
