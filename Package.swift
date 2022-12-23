// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XMLDatabase",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "XMLDatabase",
            targets: ["XMLDatabase"]),
    ],
    dependencies: [
        .package(url: "https://github.com/drmohundro/SWXMLHash.git", from: "5.0.2"),
        .package(url: "https://github.com/apple/swift-crypto.git", "1.0.0" ..< "3.0.0")
    ],
    targets: [
        .target(
            name: "XMLDatabase",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "SWXMLHash", package: "SWXMLHash"),
            ]),
        .testTarget(
            name: "XMLDatabaseTests",
            dependencies: ["XMLDatabase"])
    ]
)
