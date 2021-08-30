// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SocketIO",
    products: [
        .library(name: "SocketIO", targets: ["SocketIO"])
    ],
    targets: [
        .target(name: "SocketIO")
    ]
)
