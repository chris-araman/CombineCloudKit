// swift-tools-version:5.4

import PackageDescription

let package = Package(
  name: "CombineCloudKit",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v6),
  ],
  products: [
    .library(
      name: "CombineCloudKit",
      targets: ["CombineCloudKit"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/groue/CombineExpectations.git", from: "0.8.0"),
    .package(url: "https://github.com/apple/swift-format", .branch("swift-5.4-branch")),
  ],
  targets: [
    .target(name: "CombineCloudKit"),
    .testTarget(
      name: "CombineCloudKitTests",
      dependencies: [
        "CombineCloudKit",
        .product(
          name: "CombineExpectations",
          package: "CombineExpectations",
          // CombineExpectations does not yet support watchOS.
          condition: .when(platforms: [.iOS, .macOS, .tvOS])),
      ]
    ),
  ],
  swiftLanguageVersions: [.v5]
)
