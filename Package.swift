// swift-tools-version:5.1

import PackageDescription

let package = Package(
  name: "CombineCloudKit",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    // XCTest requires watchOS 7.4.
    .watchOS("7.4"),
  ],
  products: [
    .library(
      name: "CombineCloudKit",
      targets: ["CombineCloudKit"]
    )
  ],
  dependencies: [
    // Test improvements for Xcode 13 beta.
    .package(url: "https://github.com/groue/CombineExpectations.git", .branch("linker"))
  ],
  targets: [
    .target(name: "CombineCloudKit"),
    .testTarget(
      name: "CombineCloudKitTests",
      dependencies: [
        "CombineCloudKit",
        "CombineExpectations",
      ]
    ),
  ],
  swiftLanguageVersions: [.v5]
)

// Used by script/lint. Assumes current Swift tools.
#if swift(>=5.4)
  package.dependencies += [
    .package(url: "https://github.com/apple/swift-format", .branch("swift-5.4-branch"))
  ]
#endif

