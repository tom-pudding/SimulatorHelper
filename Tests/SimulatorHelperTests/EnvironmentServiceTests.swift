import Foundation
import Testing
@testable import SimulatorHelper

struct EnvironmentServiceTests {
    @Test
    func reportsReadyEnvironmentWhenRequiredCommandsSucceed() async {
        let runner = StubProcessRunner(
            responses: [
                StubProcessRunner.key("/usr/bin/xcodebuild", ["-version"]): .success(
                    ProcessResult(
                        standardOutput: "Xcode 26.2\nBuild version 17C52\n",
                        standardError: "",
                        exitCode: 0
                    )
                ),
                StubProcessRunner.key("/usr/bin/xcode-select", ["-p"]): .success(
                    ProcessResult(
                        standardOutput: "/Applications/Xcode.app/Contents/Developer\n",
                        standardError: "",
                        exitCode: 0
                    )
                ),
                StubProcessRunner.key("/usr/bin/xcrun", ["--find", "simctl"]): .success(
                    ProcessResult(
                        standardOutput: "/Applications/Xcode.app/Contents/Developer/usr/bin/simctl\n",
                        standardError: "",
                        exitCode: 0
                    )
                ),
                StubProcessRunner.key("/usr/bin/xcrun", ["simctl", "help", "status_bar"]): .success(
                    ProcessResult(
                        standardOutput: "Usage: simctl status_bar <device> [list | clear | override <override arguments>]\n",
                        standardError: "",
                        exitCode: 0
                    )
                ),
            ]
        )

        let status = await EnvironmentService(processRunner: runner).loadStatus()

        #expect(status.isReady)
        #expect(status.warnings.isEmpty)
        #expect(status.errors.isEmpty)
        #expect(status.xcodeVersion == "26.2")
        #expect(status.xcodeBuild == "17C52")
        #expect(status.developerDirectory == "/Applications/Xcode.app/Contents/Developer")
        #expect(status.simctlPath == "/Applications/Xcode.app/Contents/Developer/usr/bin/simctl")
        #expect(status.statusBarSupportAvailable)
    }

    @Test
    func reportsErrorWhenSimctlCannotBeFound() async {
        let runner = StubProcessRunner(
            responses: [
                StubProcessRunner.key("/usr/bin/xcodebuild", ["-version"]): .success(
                    ProcessResult(
                        standardOutput: "Xcode 26.2\nBuild version 17C52\n",
                        standardError: "",
                        exitCode: 0
                    )
                ),
                StubProcessRunner.key("/usr/bin/xcode-select", ["-p"]): .success(
                    ProcessResult(
                        standardOutput: "/Applications/Xcode.app/Contents/Developer\n",
                        standardError: "",
                        exitCode: 0
                    )
                ),
                StubProcessRunner.key("/usr/bin/xcrun", ["--find", "simctl"]): .success(
                    ProcessResult(
                        standardOutput: "",
                        standardError: "unable to find utility \"simctl\"",
                        exitCode: 72
                    )
                ),
                StubProcessRunner.key("/usr/bin/xcrun", ["simctl", "help", "status_bar"]): .success(
                    ProcessResult(
                        standardOutput: "",
                        standardError: "unable to find utility \"simctl\"",
                        exitCode: 72
                    )
                ),
            ]
        )

        let status = await EnvironmentService(processRunner: runner).loadStatus()

        #expect(!status.isReady)
        #expect(status.simctlPath == nil)
        #expect(status.errors.contains(where: { $0.contains("Unable to locate simctl via xcrun.") }))
    }

    @Test
    func reportsErrorWhenStatusBarHelpIsUnavailable() async {
        let runner = StubProcessRunner(
            responses: [
                StubProcessRunner.key("/usr/bin/xcodebuild", ["-version"]): .success(
                    ProcessResult(
                        standardOutput: "Xcode 26.2\nBuild version 17C52\n",
                        standardError: "",
                        exitCode: 0
                    )
                ),
                StubProcessRunner.key("/usr/bin/xcode-select", ["-p"]): .success(
                    ProcessResult(
                        standardOutput: "/Applications/Xcode.app/Contents/Developer\n",
                        standardError: "",
                        exitCode: 0
                    )
                ),
                StubProcessRunner.key("/usr/bin/xcrun", ["--find", "simctl"]): .success(
                    ProcessResult(
                        standardOutput: "/Applications/Xcode.app/Contents/Developer/usr/bin/simctl\n",
                        standardError: "",
                        exitCode: 0
                    )
                ),
                StubProcessRunner.key("/usr/bin/xcrun", ["simctl", "help", "status_bar"]): .success(
                    ProcessResult(
                        standardOutput: "",
                        standardError: "usage unavailable",
                        exitCode: 1
                    )
                ),
            ]
        )

        let status = await EnvironmentService(processRunner: runner).loadStatus()

        #expect(!status.isReady)
        #expect(!status.statusBarSupportAvailable)
        #expect(status.errors.contains(where: { $0.contains("Unable to verify simctl status_bar support.") }))
    }
}
