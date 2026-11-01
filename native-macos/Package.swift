// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BEYOND-MOTION",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "BEYOND-MOTION", targets: ["BEYONDMotion"])
    ],
    targets: [
        .executableTarget(
            name: "BEYONDMotion",
            path: "Sources/BEYONDMotion"
        )
    ]
)
