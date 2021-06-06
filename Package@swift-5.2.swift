// swift-tools-version:5.2

import PackageDescription

#if swift(>=5.4)
  let swiftBranch = "swift-5.4-branch"
#elseif swift(>=5.3)
  let swiftBranch = "swift-5.3-branch"
#elseif swift(>=5.2)
  let swiftBranch = "swift-5.2-branch"
#endif

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
    .package(url: "https://github.com/apple/swift-format", .branch(swiftBranch)),
  ],
  targets: [
    .target(name: "CombineCloudKit"),
    .testTarget(
      name: "CombineCloudKitTests",
      dependencies: [
        "CombineCloudKit",
        "CombineExpectations"
      ]
    ),
  ],
  swiftLanguageVersions: [.v5]
)
