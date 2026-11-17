import Foundation
import SwiftUI
import Testing
@testable import TestingLab

@Suite("Testing Lab")
struct TestingLabTests {
    @Test("A build note is identified by its commit")
    func buildNoteIdentity() {
        let note = BuildNote(
            commit: "abc1234",
            title: "Title",
            howToTest: "How",
            systemImage: "star",
            color: .orange
        )
        #expect(note.id == "abc1234")
        #expect(note.action == nil)
    }

    @Test("Opening the lab posts its notification")
    func openPostsNotification() async {
        await confirmation { opened in
            let observer = NotificationCenter.default.addObserver(
                forName: .openTestingLab,
                object: nil,
                queue: nil
            ) { _ in opened() }
            OpenTestingLabAction()()
            NotificationCenter.default.removeObserver(observer)
        }
    }

    @Test("The launch argument is claimed by the first host only")
    func launchOpeningIsClaimedOnce() {
        // Whatever the first call returns, another host in this process may have claimed it already.
        _ = LaunchOpening.claim()
        #expect(!LaunchOpening.claim())
    }

    @Test("All Screens lists destinations alphabetically, whatever order they're declared in")
    func allScreensSortsDestinations() {
        let titles = ["Settings", "about", "Level 10", "Alerts", "Level 2", "Watchlist"]
        let destinations = titles.map { LabDestination(title: $0, systemImage: "star") {} }
        let sorted = AllScreens.sorted(destinations).map(\.title)
        #expect(sorted == ["about", "Alerts", "Level 2", "Level 10", "Settings", "Watchlist"])
    }

    @Test("A destination is identified by its title")
    func destinationIdentity() {
        let destination = LabDestination(title: "Alerts", systemImage: "bell") {}
        #expect(destination.id == "Alerts")
        #expect(destination.color == .gray)
    }

    @Test("Outside the lab, closing runs the action at once")
    func closeOutsideLabRunsAction() {
        let flag = Flag()
        EnvironmentValues().closeTestingLab { flag.isSet = true }
        #expect(flag.isSet)
    }
}

private final class Flag: @unchecked Sendable {
    var isSet = false
}
