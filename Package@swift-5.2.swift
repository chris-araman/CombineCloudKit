// swift-tools-version:5.2

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

#if swift(>=5.4)
  // Test improvements for Xcode 12.5 and 13 beta.
  package.dependencies += [
    .package(url: "https://github.com/groue/CombineExpectations.git", .branch("linker"))
  ]
#else
  package.dependencies += [
    .package(url: "https://github.com/groue/CombineExpectations.git", from: "0.9.0")
  ]
#endif

// Used by script/lint. Assumes current Swift tools.
#if swift(>=5.4)
  package.dependencies += [
    .package(url: "https://github.com/apple/swift-format", .branch("swift-5.4-branch"))
  ]
#endif

