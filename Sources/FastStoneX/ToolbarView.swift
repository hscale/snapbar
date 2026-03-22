import SwiftUI
import AppKit
import CoreGraphics
import ApplicationServices

struct SnapBarView: View {
    var body: some View {
        HStack(spacing: 2) {
            gripHandle
            separator
            SnapButton(svg: "screen",  label: "Screen")  { postShortcut(key: 20) }
            SnapButton(svg: "region",  label: "Region")  { postShortcut(key: 21) }
            SnapButton(svg: "options", label: "Options") { postShortcut(key: 23) }
            separator
            SnapButton(svg: "hide",    label: "Hide")    { SnapBarPanel.shared?.hide() }
                .padding(.trailing, 2)
        }
        .padding(.horizontal, 6)
        .frame(height: 56)
        .glassEffect(.regular.interactive(), in: Capsule())
        .padding(8)
    }

    private var gripHandle: some View {
        Image(systemName: "grip.vertical")
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.quaternary)
            .frame(width: 18, height: 56)
    }

    private var separator: some View {
        Divider().frame(height: 22).padding(.horizontal, 3)
    }
}

struct SnapButton: View {
    let svg: String
    let label: String
    let action: () -> Void
    @State private var hovered = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                svgIcon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                Text(label)
                    .font(.system(size: 9, weight: .medium))
            }
            .foregroundStyle(hovered ? .primary : .secondary)
            .frame(width: 52, height: 44)
            .background(
                hovered ? AnyShapeStyle(Color.primary.opacity(0.08)) : AnyShapeStyle(Color.clear),
                in: RoundedRectangle(cornerRadius: 9)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovered = $0 }
        .animation(.easeOut(duration: 0.1), value: hovered)
    }

    private var svgIcon: Image {
        guard let url = Bundle.main.url(forResource: svg, withExtension: "svg"),
              let img = NSImage(contentsOf: url) else {
            return Image(systemName: "questionmark")
        }
        img.isTemplate = true
        return Image(nsImage: img)
    }
}

@MainActor
func postShortcut(key: CGKeyCode) {
    guard AXIsProcessTrusted() else {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
        return
    }
    SnapBarPanel.shared?.hide()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { @MainActor in
        let src = CGEventSource(stateID: .hidSystemState)
        let flags: CGEventFlags = [.maskCommand, .maskShift]
        let down = CGEvent(keyboardEventSource: src, virtualKey: key, keyDown: true)
        let up   = CGEvent(keyboardEventSource: src, virtualKey: key, keyDown: false)
        down?.flags = flags
        up?.flags   = flags
        down?.post(tap: .cghidEventTap)
        up?.post(tap: .cghidEventTap)
        SnapBarPanel.shared?.show()
    }
}
