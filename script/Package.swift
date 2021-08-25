// swift-tools-version:5.5

import PackageDescription

let package = Package(
  name: "CombineCloudKit-Scripts",
  dependencies: [
    // Used by build_docs.
    .package(url: "https://github.com/DoccZz/docc2html.git", from: "0.5.0"),
  ]
)
