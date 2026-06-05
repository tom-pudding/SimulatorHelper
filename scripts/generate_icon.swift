#!/usr/bin/env swift
// Generates SimulatorHelper.icns — zoomed iPhone status bar with 9:41, speed lines, sparkles.
import AppKit
import CoreGraphics

func drawIcon(size: Int) -> NSImage {
    let s  = CGFloat(size)
    let cx = s * 0.5
    let cy = s * 0.5

    let image = NSImage(size: NSSize(width: s, height: s))
    image.lockFocus()
    guard let ctx = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus(); return image
    }

    // ── Clip to rounded square ──────────────────────────────────────────────
    let r  = s * 0.22
    let bg = CGPath(roundedRect: CGRect(x: 0, y: 0, width: s, height: s),
                    cornerWidth: r, cornerHeight: r, transform: nil)
    ctx.addPath(bg); ctx.clip()

    // ── Background: deep blue → dark indigo gradient ────────────────────────
    let space = CGColorSpaceCreateDeviceRGB()
    let bgGrad = CGGradient(colorsSpace: space, colors: [
        CGColor(red: 0.04, green: 0.10, blue: 0.30, alpha: 1),
        CGColor(red: 0.10, green: 0.04, blue: 0.22, alpha: 1),
    ] as CFArray, locations: [0, 1])!
    ctx.drawRadialGradient(bgGrad,
                           startCenter: CGPoint(x: cx, y: cy), startRadius: 0,
                           endCenter:   CGPoint(x: cx, y: cy), endRadius: s * 0.8,
                           options: CGGradientDrawingOptions(rawValue: 3))

    // ── 集中線 (speed lines radiating from centre) ──────────────────────────
    let lineCount = 40
    for i in 0..<lineCount {
        let baseAngle = CGFloat(i) * (.pi * 2 / CGFloat(lineCount))
        let span      = CGFloat.pi * 2 / CGFloat(lineCount) * 0.45
        let dist      = s * 1.0
        ctx.move(to: CGPoint(x: cx, y: cy))
        ctx.addLine(to: CGPoint(x: cx + cos(baseAngle) * dist,
                                y: cy + sin(baseAngle) * dist))
        ctx.addLine(to: CGPoint(x: cx + cos(baseAngle + span) * dist,
                                y: cy + sin(baseAngle + span) * dist))
        ctx.closePath()
        let alpha: CGFloat = (i % 3 == 0) ? 0.13 : 0.06
        ctx.setFillColor(CGColor(red: 0.6, green: 0.8, blue: 1.0, alpha: alpha))
        ctx.fillPath()
    }

    // ── iPhone top-left corner (partial device, zoomed-in feel) ─────────────
    // Show just the upper-left portion — a thick rounded frame corner
    let frameW  = s * 0.88
    let frameH  = s * 0.72
    let frameX  = (s - frameW) / 2
    let frameY  = s * 0.16
    let frameR  = s * 0.14

    // Outer frame (phone bezel)
    let bezelPath = CGPath(roundedRect: CGRect(x: frameX, y: frameY,
                                               width: frameW, height: frameH),
                           cornerWidth: frameR, cornerHeight: frameR, transform: nil)
    ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.12))
    ctx.addPath(bezelPath); ctx.fillPath()

    ctx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.35))
    ctx.setLineWidth(s * 0.018)
    ctx.addPath(bezelPath); ctx.strokePath()

    // Screen area (inside bezel)
    let si     = s * 0.025
    let screenRect = CGRect(x: frameX + si, y: frameY + si,
                            width: frameW - si * 2, height: frameH - si * 2)
    let screenR    = frameR * 0.65
    let screenPath = CGPath(roundedRect: screenRect,
                            cornerWidth: screenR, cornerHeight: screenR, transform: nil)
    ctx.setFillColor(CGColor(red: 0.06, green: 0.14, blue: 0.38, alpha: 0.85))
    ctx.addPath(screenPath); ctx.fillPath()

    // Status bar strip at top of screen
    let sbH    = frameH * 0.20
    let sbRect = CGRect(x: frameX + si, y: frameY + frameH - si - sbH,
                        width: frameW - si * 2, height: sbH)
    let sbTopR = screenR
    // Mask: clip to screen first, then fill status bar
    ctx.saveGState()
    ctx.addPath(screenPath); ctx.clip()
    ctx.setFillColor(CGColor(red: 0.02, green: 0.08, blue: 0.25, alpha: 0.90))
    ctx.fill(sbRect)
    ctx.restoreGState()

    // ── "9:41" — large, bold, centred in the screen area ───────────────────
    let mainFontSize = s * 0.285
    let mainFont     = NSFont.monospacedDigitSystemFont(ofSize: mainFontSize, weight: .black)
    let mainAttrs: [NSAttributedString.Key: Any] = [
        .font:            mainFont,
        .foregroundColor: NSColor.white,
    ]
    let mainStr  = NSAttributedString(string: "9:41", attributes: mainAttrs)
    let mainSize = mainStr.size()
    // Centre in screen (slightly above middle to leave room for status bar)
    let screenMidY = screenRect.minY + (screenRect.height - sbH) * 0.5
    let mainX = cx - mainSize.width / 2
    let mainY = screenMidY - mainSize.height / 2
    mainStr.draw(at: NSPoint(x: mainX, y: mainY))

    // Subtle glow behind "9:41"
    ctx.saveGState()
    ctx.setShadow(offset: .zero, blur: s * 0.12,
                  color: CGColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 0.55))
    mainStr.draw(at: NSPoint(x: mainX, y: mainY))
    ctx.restoreGState()

    // Small "AM" label beneath — gives status-bar authenticity at large sizes
    if size >= 64 {
        let subFontSize = s * 0.065
        let subAttrs: [NSAttributedString.Key: Any] = [
            .font:            NSFont.monospacedDigitSystemFont(ofSize: subFontSize, weight: .medium),
            .foregroundColor: NSColor(white: 1, alpha: 0.6),
        ]
        let subStr  = NSAttributedString(string: "AM", attributes: subAttrs)
        let subSize = subStr.size()
        subStr.draw(at: NSPoint(x: cx - subSize.width / 2, y: mainY - subSize.height * 1.1))
    }

    // ── キラキラ sparkles ──────────────────────────────────────────────────
    let sparkles: [(CGFloat, CGFloat, CGFloat)] = [   // (x, y, size) as fraction of s
        (0.13, 0.80, 0.055), (0.88, 0.82, 0.040),
        (0.82, 0.25, 0.048), (0.18, 0.22, 0.035),
        (0.92, 0.52, 0.030), (0.08, 0.50, 0.032),
        (0.50, 0.08, 0.038), (0.55, 0.91, 0.028),
        (0.30, 0.92, 0.022), (0.72, 0.10, 0.025),
    ]
    for (fx, fy, fr) in sparkles {
        drawSparkle(ctx: ctx, cx: fx * s, cy: fy * s, r: fr * s)
    }

    image.unlockFocus()
    return image
}

/// Four-pointed star sparkle.
func drawSparkle(ctx: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat) {
    ctx.saveGState()
    ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.90))
    ctx.setShadow(offset: .zero, blur: r * 0.8,
                  color: CGColor(red: 0.6, green: 0.85, blue: 1.0, alpha: 0.8))
    let path = CGMutablePath()
    let arms = 4
    let inner = r * 0.22
    for i in 0..<arms * 2 {
        let angle = CGFloat(i) * .pi / CGFloat(arms) - .pi / 2
        let rad   = (i % 2 == 0) ? r : inner
        let pt    = CGPoint(x: cx + cos(angle) * rad, y: cy + sin(angle) * rad)
        i == 0 ? path.move(to: pt) : path.addLine(to: pt)
    }
    path.closeSubpath()
    ctx.addPath(path)
    ctx.fillPath()
    ctx.restoreGState()
}

func savePNG(_ image: NSImage, to path: String) {
    guard let tiff   = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let png    = bitmap.representation(using: .png, properties: [:])
    else { fputs("PNG encode failed: \(path)\n", stderr); return }
    do    { try png.write(to: URL(fileURLWithPath: path)) }
    catch { fputs("Write error \(path): \(error)\n", stderr) }
}

let sizes   = [16, 32, 64, 128, 256, 512, 1024]
let scriptDir   = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent()
let iconsetDir  = scriptDir.appendingPathComponent("AppIcon.iconset")
try? FileManager.default.createDirectory(at: iconsetDir, withIntermediateDirectories: true)

for sz in sizes {
    let img = drawIcon(size: sz)
    savePNG(img, to: iconsetDir.appendingPathComponent("icon_\(sz)x\(sz).png").path)
    if sz >= 32 {
        savePNG(img, to: iconsetDir.appendingPathComponent("icon_\(sz/2)x\(sz/2)@2x.png").path)
    }
}

let icnsPath = scriptDir.appendingPathComponent("AppIcon.icns").path
let proc     = Process()
proc.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
proc.arguments     = ["-c", "icns", iconsetDir.path, "-o", icnsPath]
try proc.run(); proc.waitUntilExit()

if proc.terminationStatus == 0 {
    print("Icon created: \(icnsPath)")
    try? FileManager.default.removeItem(at: iconsetDir)
} else {
    fputs("iconutil failed\n", stderr)
}
