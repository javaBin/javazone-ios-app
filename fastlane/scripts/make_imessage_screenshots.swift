#!/usr/bin/env swift

// Composes the two App Store screenshots for the Duke sticker pack's iMessage page.
//
// These cannot come from `fastlane ios screenshots`: capture_screenshots drives the app
// through XCUITest, and the sticker browser lives inside Apple's Messages app, which the
// test bundle cannot automate. So they are composed here from the pack's own @3x assets —
// which at least means adding a sticker and re-running this keeps them in step.
//
// The sizes are the only two ASC accepts for an iMessage app, and deliver derives the
// display type from the pixel dimensions alone (deliver/app_screenshot.rb:228), so they
// must be exact:
//   1242x2688 -> IMESSAGE_APP_IPHONE_65
//   2048x2732 -> IMESSAGE_APP_IPAD_PRO_3GEN_129
//
// 2048x2732 is in deliver's CONFLICTING_RESOLUTIONS — it is also the 2nd-gen iPad Pro
// size. deliver only picks 2nd gen when the path contains "app_ipad_pro_129", so the
// output filenames below must not contain that string.
//
// Usage: swift fastlane/scripts/make_imessage_screenshots.swift

import CoreGraphics
import CoreText
import Foundation
import ImageIO
import UniformTypeIdentifiers

// MARK: - Configuration

let repoRoot = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()  // scripts
    .deletingLastPathComponent()  // fastlane
    .deletingLastPathComponent()  // repo root

let stickerPack = repoRoot
    .appendingPathComponent("Duke/Stickers.xcassets/Sticker Pack.stickerpack")
let logoPath = repoRoot
    .appendingPathComponent("JavaZone/Assets.xcassets/LaunchScreenLogo.imageset/JZ26-Splash-iphone-3x.png")
let outputDir = repoRoot
    .appendingPathComponent("fastlane/screenshots/iMessage/en-US")

let caption = "Duke stickers for every JavaZone"

// The stickers to feature, in order. Anything not listed here is ignored, so adding a
// sticker to the pack does not silently push a chosen one out of the grid — but a name
// that no longer exists is a hard error rather than a quiet gap.
let featured = [
    // The first 12 fill the iPhone grid, so they are ordered for variety: the regional
    // Dukes share one silhouette and read as repetition when they sit next to each other.
    "jz26_trident_duke",
    "viking_duke",
    "duke_umbrella",
    "nisse_duke",
    "rock_duke",
    "duke_bergen",
    "marius_duke",
    "tetris_duke3",
    "jz24_mc",
    "roman",
    "jz_item_heart",
    "duke_oslo",
    // The remaining 8 only appear in the iPad grid.
    "duke_trondheim",
    "duke_stavanger",
    "duke_tromso",
    "duke_sogn",
    "duke_vestfold",
    "duke_sorlandet",
    "jz24_usb_duke",
    "bart_duke",
]

struct Layout {
    let name: String
    let width: Int
    let height: Int
    let columns: Int
    let rows: Int
}

let layouts = [
    Layout(name: "1_Stickers-iphone65", width: 1242, height: 2688, columns: 3, rows: 4),
    Layout(name: "1_Stickers-ipad13", width: 2048, height: 2732, columns: 5, rows: 4),
]

// JZ26 branding: coral on white.
let coral = CGColor(srgbRed: 0.96, green: 0.45, blue: 0.44, alpha: 1.0)
let ink = CGColor(srgbRed: 0.13, green: 0.13, blue: 0.15, alpha: 1.0)
let paper = CGColor(srgbRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
// The tile has to stay clearly darker than the Dukes' white bodies — most of the
// regional stickers are white-on-black line art and vanish against an off-white tile.
let tile = CGColor(srgbRed: 0.91, green: 0.91, blue: 0.93, alpha: 1.0)

// MARK: - Helpers

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data("error: \(message)\n".utf8))
    exit(1)
}

func loadImage(_ url: URL) -> CGImage {
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
          let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
    else {
        fail("could not read image at \(url.path)")
    }
    return image
}

/// Resolves a sticker name to its highest-resolution PNG. The pack is not consistent —
/// most stickers ship an @3x, JavaZone2021 ships an unsuffixed file.
func stickerImage(named name: String) -> CGImage {
    let dir = stickerPack.appendingPathComponent("\(name).sticker")
    let candidates = ["\(name)@3x.png", "\(name)@2x.png", "\(name).png"]
    for candidate in candidates {
        let url = dir.appendingPathComponent(candidate)
        if FileManager.default.fileExists(atPath: url.path) {
            return loadImage(url)
        }
    }
    fail("no PNG found for sticker '\(name)' in \(dir.path)")
}

/// Fits `size` inside `bounds` without cropping, centred.
func aspectFit(size: CGSize, in bounds: CGRect) -> CGRect {
    let scale = min(bounds.width / size.width, bounds.height / size.height)
    let fitted = CGSize(width: size.width * scale, height: size.height * scale)
    return CGRect(
        x: bounds.midX - fitted.width / 2,
        y: bounds.midY - fitted.height / 2,
        width: fitted.width,
        height: fitted.height
    )
}

func drawCentredText(
    _ text: String,
    in context: CGContext,
    fontSize: CGFloat,
    color: CGColor,
    centreX: CGFloat,
    baselineY: CGFloat
) {
    let font = CTFontCreateWithName("Helvetica-Bold" as CFString, fontSize, nil)
    // Foundation alone has no .font / .foregroundColor attribute keys — those are AppKit's.
    // Spell them with CoreText's own key names so this stays a dependency-free script.
    let attributed = NSAttributedString(
        string: text,
        attributes: [
            NSAttributedString.Key(kCTFontAttributeName as String): font,
            NSAttributedString.Key(kCTForegroundColorAttributeName as String): color,
        ]
    )
    let line = CTLineCreateWithAttributedString(attributed)
    let bounds = CTLineGetBoundsWithOptions(line, .useOpticalBounds)
    context.textPosition = CGPoint(x: centreX - bounds.width / 2, y: baselineY)
    CTLineDraw(line, context)
}

func write(_ image: CGImage, to url: URL) {
    guard let destination = CGImageDestinationCreateWithURL(
        url as CFURL, UTType.png.identifier as CFString, 1, nil
    ) else {
        fail("could not create PNG destination at \(url.path)")
    }
    CGImageDestinationAddImage(destination, image, nil)
    guard CGImageDestinationFinalize(destination) else {
        fail("could not write PNG at \(url.path)")
    }
}

// MARK: - Rendering

func render(_ layout: Layout, logo: CGImage, stickers: [CGImage]) -> CGImage {
    guard let context = CGContext(
        data: nil,
        width: layout.width,
        height: layout.height,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: CGColorSpace(name: CGColorSpace.sRGB)!,
        // noneSkipLast drops the alpha channel from the written PNG. App Store
        // screenshots with an alpha channel are rejected at upload — the same trap the
        // sticker pack's app icon hit with error 90647 (see README).
        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
    ) else {
        fail("could not create a \(layout.width)x\(layout.height) bitmap context")
    }

    let width = CGFloat(layout.width)
    let height = CGFloat(layout.height)
    let margin = width * 0.07

    // App Store screenshots are rejected with an alpha channel, so paint the ground
    // opaque rather than relying on the context's cleared state.
    context.setFillColor(paper)
    context.fill(CGRect(x: 0, y: 0, width: width, height: height))

    // CoreGraphics is bottom-left origin; everything below is laid out from the top by
    // subtracting from `height`.

    // Logo, top-aligned.
    let logoBox = CGRect(
        x: margin,
        y: height - margin - height * 0.10,
        width: width - margin * 2,
        height: height * 0.10
    )
    context.draw(logo, in: aspectFit(
        size: CGSize(width: logo.width, height: logo.height), in: logoBox
    ))

    // Caption under the logo.
    let captionSize = width * 0.042
    let captionBaseline = logoBox.minY - captionSize * 1.6
    drawCentredText(
        caption,
        in: context,
        fontSize: captionSize,
        color: ink,
        centreX: width / 2,
        baselineY: captionBaseline
    )

    // Coral rule between the caption and the grid.
    let ruleY = captionBaseline - captionSize * 0.9
    context.setFillColor(coral)
    context.fill(CGRect(
        x: width / 2 - width * 0.08,
        y: ruleY,
        width: width * 0.16,
        height: max(3, width * 0.005)
    ))

    // Sticker grid, filling what is left below the rule.
    let gridTop = ruleY - margin
    let gridBottom = margin
    let gridHeight = gridTop - gridBottom
    let gridWidth = width - margin * 2
    let cellWidth = gridWidth / CGFloat(layout.columns)
    let cellHeight = gridHeight / CGFloat(layout.rows)
    let padding = min(cellWidth, cellHeight) * 0.10
    let corner = min(cellWidth, cellHeight) * 0.14

    for (index, sticker) in stickers.prefix(layout.columns * layout.rows).enumerated() {
        let column = index % layout.columns
        let row = index / layout.columns
        let cell = CGRect(
            x: margin + CGFloat(column) * cellWidth,
            y: gridTop - CGFloat(row + 1) * cellHeight,
            width: cellWidth,
            height: cellHeight
        ).insetBy(dx: padding, dy: padding)

        context.setFillColor(tile)
        context.addPath(CGPath(roundedRect: cell, cornerWidth: corner, cornerHeight: corner, transform: nil))
        context.fillPath()

        let inner = cell.insetBy(dx: cell.width * 0.10, dy: cell.height * 0.10)
        context.draw(sticker, in: aspectFit(
            size: CGSize(width: sticker.width, height: sticker.height), in: inner
        ))
    }

    guard let image = context.makeImage() else { fail("could not snapshot the context") }
    return image
}

// MARK: - Main

let needed = layouts.map { $0.columns * $0.rows }.max() ?? 0
guard featured.count >= needed else {
    fail("`featured` lists \(featured.count) stickers but the largest grid needs \(needed)")
}

let logo = loadImage(logoPath)
let stickers = featured.map(stickerImage(named:))

try? FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)

for layout in layouts {
    let url = outputDir.appendingPathComponent("\(layout.name).png")
    write(render(layout, logo: logo, stickers: stickers), to: url)
    print("wrote \(layout.width)x\(layout.height)  \(url.path)")
}
