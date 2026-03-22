import AppKit
import SwiftUI

@MainActor
final class SnapBarPanel: NSPanel, NSWindowDelegate {
    static var shared: SnapBarPanel?

    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 70),
            styleMask: [.nonactivatingPanel, .borderless, .utilityWindow],
            backing: .buffered,
            defer: false
        )
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        isMovableByWindowBackground = true
        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        delegate = self
        contentView = NSHostingView(rootView: SnapBarView())
        restoreOrCenter()
    }

    func show() { orderFrontRegardless() }
    func hide() { orderOut(nil) }

    func windowDidMove(_ notification: Notification) {
        UserDefaults.standard.set(frame.origin.x, forKey: "snapbar.x")
        UserDefaults.standard.set(frame.origin.y, forKey: "snapbar.y")
    }

    private func restoreOrCenter() {
        let d = UserDefaults.standard
        if d.object(forKey: "snapbar.x") != nil {
            setFrameOrigin(NSPoint(x: d.double(forKey: "snapbar.x"), y: d.double(forKey: "snapbar.y")))
        } else {
            positionNearTopCenter()
        }
    }

    private func positionNearTopCenter() {
        guard let screen = NSScreen.main else { return }
        let x = (screen.frame.width - frame.width) / 2
        let y = screen.frame.height - 100
        setFrameOrigin(NSPoint(x: x, y: y))
    }
}
