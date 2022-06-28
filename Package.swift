// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// Name of the Package
let name = "PromiseLite"

/// Suported Platforms of the Package
let platforms: [SupportedPlatform] = [
  .iOS( .v9 ),
  .tvOS( .v9 ),
  .watchOS( .v2),
  .macOS( .v10_10) ]

/// Products of the Package
let products: [Product] = [
  .library(name: name, targets: [ name ])
]

/// Dependencies for the Target(s)
let targetTestDependencies: [Target.Dependency] = [
  Target.Dependency(stringLiteral: name)
]

/// Targets of the Package
let targets: [Target] = [
  .target(
    name: name,
    path: "\(name)/Classes"
  ),
  .testTarget(
    name: "\(name)Tests",
    dependencies: targetTestDependencies,
    path: "\(name)/Tests"
  )
]

/// Supported Swift Version of the Package
let languagesVersions: [SwiftVersion] = [ .v5 ]

/// The Package
let package = Package(
  name: name,
  platforms: platforms,
  products: products,
  targets: targets,
  swiftLanguageVersions: languagesVersions
)
