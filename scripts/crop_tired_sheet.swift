#!/usr/bin/env swift
import Foundation
import ImageIO
import CoreGraphics
import UniformTypeIdentifiers

guard CommandLine.arguments.count >= 3 else {
    fputs("Usage: crop_tired_sheet.swift <input.png> <out_dir>\n", stderr)
    exit(1)
}
let inputPath = CommandLine.arguments[1]
let outDir = CommandLine.arguments[2]
try FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true)

guard let data = try? Data(contentsOf: URL(fileURLWithPath: inputPath)),
      let src = CGImageSourceCreateWithData(data as CFData, nil),
      let cg = CGImageSourceCreateImageAtIndex(src, 0, nil) else {
    fputs("Cannot load image\n", stderr)
    exit(1)
}

let W = cg.width
let H = cg.height

/// CGImage crop rect: origin **bottom-left**, y measured upward.
func crop(_ cg: CGImage, rect: CGRect) -> CGImage? {
    cg.cropping(to: rect)
}

func writePNG(_ image: CGImage, path: String) {
    let url = URL(fileURLWithPath: path) as CFURL
    guard let dest = CGImageDestinationCreateWithURL(url, UTType.png.identifier as CFString, 1, nil) else {
        fputs("Cannot create destination \(path)\n", stderr)
        exit(1)
    }
    CGImageDestinationAddImage(dest, image, nil)
    CGImageDestinationFinalize(dest)
}

let hBg = Int(Double(H) * 0.38)
let hMid = Int(Double(H) * 0.47)
let hWave = H - hBg - hMid
let midW = W / 2

let bgRect = CGRect(x: 0, y: H - hBg, width: W, height: hBg)
let raftOpenRect = CGRect(x: 0, y: hWave, width: midW, height: hMid)
let raftClosedRect = CGRect(x: midW, y: hWave, width: midW, height: hMid)
guard let imgBg = crop(cg, rect: bgRect),
      let imgOpen = crop(cg, rect: raftOpenRect),
      let imgClosed = crop(cg, rect: raftClosedRect) else {
    fputs("Crop failed\n", stderr)
    exit(1)
}

writePNG(imgBg, path: "\(outDir)/sunset_ocean_background.png")
writePNG(imgOpen, path: "\(outDir)/healy_raft.png")
writePNG(imgClosed, path: "\(outDir)/healy_raft_eyes_closed.png")

print("OK \(W)×\(H) → \(outDir)")
