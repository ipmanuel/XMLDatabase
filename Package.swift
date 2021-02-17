// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XMLDatabase",
    products: [
        .library(
            name: "XMLDatabase",
            targets: ["XMLDatabase"]),
    ],
    dependencies: [
        .package(url: "https://github.com/drmohundro/SWXMLHash.git", from: "5.0.2")    
    ],
    targets: [
        .target(
            name: "XMLDatabase",
            dependencies: ["SWXMLHash"]),
        .testTarget(
            name: "XMLDatabaseTests",
            dependencies: ["XMLDatabase"])
    ]
)
