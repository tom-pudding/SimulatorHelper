#!/usr/bin/env swift
// Generates SimulatorHelper.icns in the Resources directory next to this script.
import AppKit
import CoreGraphics
import CoreText

func drawIcon(size: Int) -> NSImage {
    let s = CGFloat(size)
    let image = NSImage(size: NSSize(width: s, height: s))
    image.lockFocus()
    guard let ctx = NSGraphicsContext.current?.cgContext else { image.unlockFocus(); return image }

    // --- Background: blue→indigo gradient, rounded ---
    let radius = s * 0.22
    let bgPath = CGPath(roundedRect: CGRect(x: 0, y: 0, width: s, height: s),
                        cornerWidth: radius, cornerHeight: radius, transform: nil)
    ctx.addPath(bgPath)
    ctx.clip()

    let space = CGColorSpaceCreateDeviceRGB()
    let bgColors = [
        CGColor(red: 0.18, green: 0.50, blue: 1.00, alpha: 1),
        CGColor(red: 0.10, green: 0.28, blue: 0.82, alpha: 1),
    ] as CFArray
    let bgGrad = CGGradient(colorsSpace: space, colors: bgColors, locations: [0, 1])!
    ctx.drawLinearGradient(bgGrad,
                           start: CGPoint(x: s * 0.5, y: s),
                           end:   CGPoint(x: s * 0.5, y: 0),
                           options: [])
    ctx.resetClip()

    // --- Phone body ---
    let pw = s * 0.42          // phone width
    let ph = s * 0.62          // phone height
    let px = (s - pw) / 2
    let py = (s - ph) / 2 + s * 0.02
    let pr = pw * 0.18         // phone corner radius

    // Drop shadow
    ctx.setShadow(offset: CGSize(width: 0, height: -s * 0.02),
                  blur: s * 0.06,
                  color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.35))
    let phoneRect = CGRect(x: px, y: py, width: pw, height: ph)
    let phonePath = CGPath(roundedRect: phoneRect, cornerWidth: pr, cornerHeight: pr, transform: nil)
    ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.95))
    ctx.addPath(phonePath)
    ctx.fillPath()
    ctx.setShadow(offset: .zero, blur: 0, color: nil)

    // Phone screen (inset)
    let si  = pw * 0.07
    let screenRect = CGRect(x: px + si, y: py + si * 0.8,
                            width: pw - si * 2, height: ph - si * 1.6)
    let screenPath = CGPath(roundedRect: screenRect,
                            cornerWidth: pr * 0.5, cornerHeight: pr * 0.5, transform: nil)
    ctx.setFillColor(CGColor(red: 0.12, green: 0.32, blue: 0.78, alpha: 1))
    ctx.addPath(screenPath)
    ctx.fillPath()

    // Status bar stripe
    let sbH  = ph * 0.13
    let sbRect = CGRect(x: px + si, y: py + ph - si * 0.8 - sbH,
                        width: pw - si * 2, height: sbH)
    let sbTR = pr * 0.4
    let sbPath = CGPath(roundedRect: sbRect,
                        cornerWidth: sbTR, cornerHeight: sbTR, transform: nil)
    ctx.setFillColor(CGColor(red: 0.06, green: 0.20, blue: 0.60, alpha: 1))
    ctx.addPath(sbPath)
    ctx.fillPath()

    // "9:41" text in status bar
    let fontSize = sbH * 0.56
    let attrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.monospacedDigitSystemFont(ofSize: fontSize, weight: .semibold),
        .foregroundColor: NSColor.white,
    ]
    let label = NSAttributedString(string: "9:41", attributes: attrs)
    let labelSize = label.size()
    let labelX = sbRect.midX - labelSize.width / 2
    let labelY = sbRect.midY - labelSize.height / 2
    label.draw(at: NSPoint(x: labelX, y: labelY))

    // Home indicator bar
    let hiW = pw * 0.30
    let hiH = ph * 0.015
    let hiX = px + (pw - hiW) / 2
    let hiY = py + ph * 0.045
    let hiPath = CGPath(roundedRect: CGRect(x: hiX, y: hiY, width: hiW, height: hiH),
                        cornerWidth: hiH / 2, cornerHeight: hiH / 2, transform: nil)
    ctx.setFillColor(CGColor(red: 0.55, green: 0.65, blue: 0.85, alpha: 0.8))
    ctx.addPath(hiPath)
    ctx.fillPath()

    image.unlockFocus()
    return image
}

func savePNG(_ image: NSImage, to path: String) {
    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let png = bitmap.representation(using: .png, properties: [:]) else {
        fputs("Failed to encode PNG: \(path)\n", stderr); return
    }
    do { try png.write(to: URL(fileURLWithPath: path)) }
    catch { fputs("Write error \(path): \(error)\n", stderr) }
}

// Sizes required by macOS iconset
let sizes = [16, 32, 64, 128, 256, 512, 1024]

let scriptDir = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent()
let iconsetDir = scriptDir.appendingPathComponent("AppIcon.iconset")

try? FileManager.default.createDirectory(at: iconsetDir, withIntermediateDirectories: true)

for sz in sizes {
    let img = drawIcon(size: sz)
    savePNG(img, to: iconsetDir.appendingPathComponent("icon_\(sz)x\(sz).png").path)
    // @2x variant (same image, labelled as half the logical size)
    if sz >= 32 {
        savePNG(img, to: iconsetDir.appendingPathComponent("icon_\(sz/2)x\(sz/2)@2x.png").path)
    }
}

let icnsPath = scriptDir.appendingPathComponent("AppIcon.icns").path
let result = Process()
result.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
result.arguments = ["-c", "icns", iconsetDir.path, "-o", icnsPath]
try result.run(); result.waitUntilExit()

if result.terminationStatus == 0 {
    print("Icon created: \(icnsPath)")
    try? FileManager.default.removeItem(at: iconsetDir)
} else {
    fputs("iconutil failed\n", stderr)
}
