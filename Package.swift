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
  dependencies: [
    .package(url: "https://github.com/groue/CombineExpectations.git", from: "0.10.0"),
    // https://github.com/groue/CombineTraits/pull/5
    .package(url: "https://github.com/chris-araman/CombineTraits.git", .branch("support")),
  ],
  targets: [
    .target(
      name: "CombineCloudKit",
      dependencies: ["CombineTraits"]
    ),
    .testTarget(
      name: "CombineCloudKitTests",
      dependencies: ["CombineCloudKit", "CombineExpectations"]
    ),
  ],
  swiftLanguageVersions: [.v5]
)

#if swift(>=5.4)
  // XCTest for watchOS requires watchOS 7.4 and Swift 5.4.
  package.platforms! += [
    .watchOS("7.4")
  ]
#else
  // Combine requires watchOS 6.
  package.platforms! += [
    .watchOS(.v6)
  ]
#endif
