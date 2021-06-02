// swift-tools-version:5.1

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
  targets: [
    .target(name: "CombineCloudKit")
  ],
  swiftLanguageVersions: [.v5]
)
