// swift-tools-version:5.5
import PackageDescription

let package =
  Package(
    name: "SwiftUIHaptics",
    platforms: [
      .iOS(.v15),
      .watchOS(.v8),
      .macOS(.v12),
    ],
    products: [
      .library(
        name: "SwiftUIHaptics",
        targets: ["SwiftUIHaptics"]
      ),
    ],
    dependencies: [
      .package(
        name: "SwiftFoundationExtensions",
        url: "https://github.com/xiiagency/SwiftFoundationExtensions",
        .upToNextMinor(from: "1.0.0")
      ),
    ],
    targets: [
      .target(
        name: "SwiftUIHaptics",
        dependencies: [
          "SwiftFoundationExtensions"
        ]
      ),
    ]
  )
