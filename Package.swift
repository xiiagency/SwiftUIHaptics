// swift-tools-version:5.5
import PackageDescription

let package =
  Package(
    name: "SwiftUIHaptics",
    platforms: [
      .iOS(.v15),
      .watchOS(.v8),
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
        .branchItem("main")
      ),
    ],
    targets: [
      .target(
        name: "SwiftUIHaptics",
        dependencies: [
          "SwiftFoundationExtensions"
        ]
      ),
      // NOTE: Re-enable when tests are added.
//      .testTarget(
//        name: "SwiftUIHapticsTests",
//        dependencies: ["SwiftUIHaptics"]
//      ),
    ]
  )
