#!/usr/bin/swift
import AppKit
import CoreGraphics

func drawIcon(size: CGFloat) -> NSImage {
    let img = NSImage(size: NSSize(width: size, height: size))
    img.lockFocus()
    let ctx = NSGraphicsContext.current!.cgContext
    let s = size

    // --- Background: deep blue rounded rect ---
    let r = s * 0.225
    let bg = CGPath(roundedRect: CGRect(x: 0, y: 0, width: s, height: s),
                    cornerWidth: r, cornerHeight: r, transform: nil)
    ctx.saveGState()
    ctx.addPath(bg)
    ctx.clip()
    let cols = [CGColor(red:0.09,green:0.38,blue:0.85,alpha:1),
                CGColor(red:0.04,green:0.18,blue:0.55,alpha:1)] as CFArray
    let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                          colors: cols, locations: [0.0,1.0])!
    ctx.drawLinearGradient(grad,
        start: CGPoint(x: s*0.5, y: s),
        end:   CGPoint(x: s*0.5, y: 0), options: [])
    ctx.restoreGState()

    // --- Screen frame (monitor outline) ---
    let mW = s * 0.62, mH = s * 0.44
    let mX = (s - mW) / 2, mY = s * 0.30
    let mR = s * 0.06
    ctx.setStrokeColor(CGColor(red:1,green:1,blue:1,alpha:1))
    ctx.setFillColor(CGColor(red:1,green:1,blue:1,alpha:0.12))
    ctx.setLineWidth(s * 0.048)
    let mPath = CGPath(roundedRect: CGRect(x: mX, y: mY, width: mW, height: mH),
                       cornerWidth: mR, cornerHeight: mR, transform: nil)
    ctx.addPath(mPath)
    ctx.fillPath()
    ctx.addPath(mPath)
    ctx.strokePath()

    // --- Crosshair / cursor inside screen ---
    let cx = s * 0.50, cy = mY + mH * 0.52
    let arm = mW * 0.18
    ctx.setStrokeColor(CGColor(red:1,green:1,blue:1,alpha:0.95))
    ctx.setLineWidth(s * 0.038)
    ctx.setLineCap(.round)

    ctx.move(to: CGPoint(x: cx - arm, y: cy))
    ctx.addLine(to: CGPoint(x: cx + arm, y: cy))
    ctx.move(to: CGPoint(x: cx, y: cy - arm))
    ctx.addLine(to: CGPoint(x: cx, y: cy + arm))
    ctx.strokePath()

    let dotR = s * 0.032
    ctx.setFillColor(CGColor(red:1,green:1,blue:1,alpha:1))
    ctx.fillEllipse(in: CGRect(x: cx - dotR, y: cy - dotR, width: dotR*2, height: dotR*2))

    // --- Dashed selection box around crosshair ---
    let bPad = mW * 0.16
    let bRect = CGRect(x: mX + bPad, y: mY + mH * 0.18,
                       width: mW - bPad*2, height: mH * 0.66)
    ctx.setStrokeColor(CGColor(red:1,green:1,blue:1,alpha:0.80))
    ctx.setLineWidth(s * 0.036)
    ctx.setLineDash(phase: 0, lengths: [s*0.06, s*0.035])
    let bPath = CGPath(roundedRect: bRect, cornerWidth: s*0.03, cornerHeight: s*0.03, transform: nil)
    ctx.addPath(bPath)
    ctx.strokePath()
    ctx.setLineDash(phase: 0, lengths: [])

    // --- Solid corner handles on selection box ---
    ctx.setStrokeColor(CGColor(red:1,green:1,blue:1,alpha:1))
    ctx.setLineWidth(s * 0.055)
    let hLen = s * 0.075
    let corners: [(CGFloat, CGFloat)] = [
        (bRect.minX, bRect.minY), (bRect.maxX, bRect.minY),
        (bRect.minX, bRect.maxY), (bRect.maxX, bRect.maxY)
    ]
    for (px, py) in corners {
        let dx: CGFloat = px < s/2 ? 1 : -1
        let dy: CGFloat = py < s/2 ? 1 : -1
        ctx.move(to: CGPoint(x: px + dx*hLen, y: py))
        ctx.addLine(to: CGPoint(x: px, y: py))
        ctx.addLine(to: CGPoint(x: px, y: py + dy*hLen))
    }
    ctx.strokePath()

    // --- Monitor stand ---
    ctx.setStrokeColor(CGColor(red:1,green:1,blue:1,alpha:0.75))
    ctx.setLineWidth(s * 0.046)
    ctx.setLineCap(.round)
    let standX = s * 0.50
    ctx.move(to: CGPoint(x: standX, y: mY))
    ctx.addLine(to: CGPoint(x: standX, y: mY - s*0.10))
    ctx.strokePath()
    let baseW = s * 0.22
    ctx.move(to: CGPoint(x: standX - baseW/2, y: mY - s*0.10))
    ctx.addLine(to: CGPoint(x: standX + baseW/2, y: mY - s*0.10))
    ctx.strokePath()

    img.unlockFocus()
    return img
}

func savePNG(_ image: NSImage, to path: String) {
    let rep = NSBitmapImageRep(data: image.tiffRepresentation!)!
    try! rep.representation(using: .png, properties: [:])!
        .write(to: URL(fileURLWithPath: path))
}

let outputDir = CommandLine.arguments[1]
try! FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)

let sizes: [(Int, String)] = [
    (16,   "icon_16x16"),
    (32,   "icon_16x16@2x"),
    (32,   "icon_32x32"),
    (64,   "icon_32x32@2x"),
    (128,  "icon_128x128"),
    (256,  "icon_128x128@2x"),
    (256,  "icon_256x256"),
    (512,  "icon_256x256@2x"),
    (512,  "icon_512x512"),
    (1024, "icon_512x512@2x")
]

for (size, name) in sizes {
    savePNG(drawIcon(size: CGFloat(size)), to: "\(outputDir)/\(name).png")
    print("done \(name).png")
}
