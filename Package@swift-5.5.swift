// swift-tools-version:5.5

import PackageDescription

let package = Package(
  name: "CombineCloudKit",
  // Combine requires macOS 10.15, Mac Catalyst 13, iOS 13, tvOS 13, or watchOS 6.
  // XCTest requires watchOS 7.4.
  platforms: [
    .macCatalyst(.v13),
    .macOS(.v10_15),
    .iOS(.v13),
    .tvOS(.v13),
    .watchOS("7.4"),
  ],
  products: [
    .library(
      name: "CombineCloudKit",
      targets: ["CombineCloudKit"]
    )
  ],
  dependencies: [
    // Used by script/lint. Assumes current Swift tools.
    .package(url: "https://github.com/apple/swift-format.git", .branch("swift-5.5-branch")),
  ],
  targets: [
    .target(name: "CombineCloudKit"),
    .testTarget(
      name: "CombineCloudKitTests",
      dependencies: ["CombineCloudKit"]
    ),
  ],
  swiftLanguageVersions: [.v5]
)
