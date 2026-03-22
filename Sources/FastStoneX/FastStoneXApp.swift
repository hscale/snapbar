import SwiftUI
import AppKit
import ApplicationServices

@main
struct SnapBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        MenuBarExtra {
            Button { postShortcut(key: 20) } label: {
                Label("Full Screen", systemImage: "rectangle.on.rectangle")
            }
            Button { postShortcut(key: 21) } label: {
                Label("Region / Window", systemImage: "rectangle.dashed")
            }
            Button { postShortcut(key: 23) } label: {
                Label("Screenshot Options", systemImage: "camera.viewfinder")
            }
            Divider()
            Button("Show Toolbar") { SnapBarPanel.shared?.show() }
            Divider()
            Button("Quit SnapBar") { NSApp.terminate(nil) }
        } label: {
            Image(systemName: "camera.viewfinder")
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        requestAccessibilityIfNeeded()
        let panel = SnapBarPanel()
        SnapBarPanel.shared = panel
        panel.show()
    }

    private func requestAccessibilityIfNeeded() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }
}
