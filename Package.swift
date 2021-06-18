// swift-tools-version:5.1

import PackageDescription

let package = Package(
  name: "CombineCloudKit",
  // Combine requires macOS 10.15, iOS 13, or tvOS 13.
  platforms: [
    .macOS(.v10_15),
    .iOS(.v13),
    .tvOS(.v13),
  ],
  products: [
    .library(
      name: "CombineCloudKit",
      targets: ["CombineCloudKit"]
    )
  ],
  targets: [
    .target(name: "CombineCloudKit")
  ],
  swiftLanguageVersions: [.v5]
)

#if swift(>=5.2)
  // CombineCloudKitTests require Swift 5.2.
  package.platforms += [
    // XCTest requires watchOS 7.4.
    .watchOS("7.4"),
  ]
  package.dependencies += [
    // Test improvements for Xcode 13 beta.
    .package(url: "https://github.com/groue/CombineExpectations.git", .branch("linker"))
  ]
  package.targets += [
    .testTarget(
      name: "CombineCloudKitTests",
      dependencies: [
        "CombineCloudKit",
        "CombineExpectations",
      ]
    ),
  ]
#else
  // Combine requires watchOS 6.
  package.platforms += [
    .watchOS(v6),
  ]
#endif

// Used by script/lint. Assumes current Swift tools.
#if swift(>=5.4)
  package.dependencies += [
    .package(url: "https://github.com/apple/swift-format", .branch("swift-5.4-branch"))
  ]
#endif

