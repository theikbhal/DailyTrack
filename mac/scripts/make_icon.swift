import AppKit

let args = CommandLine.arguments
guard args.count >= 2 else {
    print("Usage: swift make_icon.swift <output.png>")
    exit(1)
}
let output = args[1]
let size: CGFloat = 1024

let image = NSImage(size: NSSize(width: size, height: size))
image.lockFocus()

let bg = NSBezierPath(roundedRect: NSRect(x: 0, y: 0, width: size, height: size), xRadius: 200, yRadius: 200)
let gradient = NSGradient(colors: [
    NSColor(calibratedRed: 0.06, green: 0.62, blue: 0.68, alpha: 1),
    NSColor(calibratedRed: 0.20, green: 0.24, blue: 0.62, alpha: 1)
])!
gradient.draw(in: bg, angle: -45)

let frame = NSBezierPath(roundedRect: NSRect(x: 150, y: 200, width: 724, height: 624), xRadius: 60, yRadius: 60)
NSColor(calibratedWhite: 1, alpha: 0.16).setFill()
frame.fill()
NSColor(calibratedWhite: 1, alpha: 0.75).setStroke()
frame.lineWidth = 14
frame.stroke()

let beamY: CGFloat = 470
let beam = NSBezierPath(rect: NSRect(x: 180, y: beamY - 18, width: 664, height: 36))
NSColor(calibratedRed: 0.98, green: 0.80, blue: 0.35, alpha: 1).setFill()
beam.fill()

let rods = 5
let startX: CGFloat = 240
let gap: CGFloat = 145
for i in 0..<rods {
    let x = startX + CGFloat(i) * gap
    let rod = NSBezierPath(rect: NSRect(x: x - 9, y: 230, width: 18, height: 564))
    NSColor(calibratedWhite: 1, alpha: 0.55).setFill()
    rod.fill()

    let heavenY: CGFloat = i % 2 == 0 ? beamY + 90 : beamY + 40
    let heaven = NSBezierPath(ovalIn: NSRect(x: x - 58, y: heavenY - 34, width: 116, height: 68))
    NSColor(calibratedRed: 0.98, green: 0.80, blue: 0.35, alpha: 1).setFill()
    heaven.fill()

    let beads = i % 3 == 0 ? 3 : 2
    for j in 0..<beads {
        let y = CGFloat(j) * 78 + 250
        let bead = NSBezierPath(ovalIn: NSRect(x: x - 58, y: y, width: 116, height: 68))
        NSColor(calibratedWhite: 1, alpha: 0.95).setFill()
        bead.fill()
    }
}

image.unlockFocus()

guard let tiff = image.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let png = rep.representation(using: .png, properties: [:]) else {
    print("failed to render icon")
    exit(1)
}
try? png.write(to: URL(fileURLWithPath: output))
print("wrote \(output)")
