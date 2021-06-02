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
  dependencies: [
    .package(url: "https://github.com/groue/CombineExpectations.git", from: "0.8.0")
  ],
  targets: [
    .target(
      name: "CombineCloudKit",
      dependencies: []
    ),
    .testTarget(
      name: "CombineCloudKitTests",
      dependencies: ["CombineCloudKit", "CombineExpectations"]
    ),
  ],
  swiftLanguageVersions: [.v5]
)

#if compiler(>=5.4)
  package.dependencies +=
    [.package(url: "https://github.com/apple/swift-format", .branch("swift-5.4-branch"))]
#elseif compiler(>=5.3)
  package.dependencies +=
    [.package(url: "https://github.com/apple/swift-format", .branch("swift-5.3-branch"))]
#elseif compiler(>=5.2)
  package.dependencies +=
    [.package(url: "https://github.com/apple/swift-format", .branch("swift-5.2-branch"))]
#elseif compiler(>=5.1)
  package.dependencies +=
    [.package(url: "https://github.com/apple/swift-format", .branch("swift-5.1-branch"))]
#endif
