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
