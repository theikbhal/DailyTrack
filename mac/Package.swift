// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DailyTrack",
    platforms: [.macOS(.v14)],
    products: [.executable(name: "DailyTrack", targets: ["DailyTrack"])],
    targets: [.executableTarget(name: "DailyTrack", path: "Sources/DailyTrack")]
)
