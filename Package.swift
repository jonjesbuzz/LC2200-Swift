// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "LC2200Kit",
    products: [
        .library(
            name: "LC2200Kit", targets: ["LC2200Kit"]
        ),
        .executable(name: "lc2200", targets: ["lc2200"]),
    ],
    targets: [
        .target(name: "LC2200Kit", dependencies: []),
        .target(name: "lc2200", dependencies: ["LC2200Kit"])
    ]
)