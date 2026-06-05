// swift-tools-version: 6.3.1

import PackageDescription

let package = Package(
    name: "swift-list-linked-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(
            name: "List Linked Primitives",
            targets: ["List Linked Primitives"]
        ),
        .library(
            name: "List Linked Primitive",
            targets: ["List Linked Primitive"]
        ),
        .library(
            name: "List Linked Primitives Test Support",
            targets: ["List Linked Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-list-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-buffer-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-buffer-linked-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-index-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-property-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-iterator-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-sequence-primitives.git", branch: "main"),
        // E2 (storage-small-substrate.md): verbose Storage.Contiguous<Memory.Heap> needs direct deps (MemberImportVisibility).
        .package(url: "https://github.com/swift-primitives/swift-storage-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-memory-heap-primitives.git", branch: "main"),
    ],
    targets: [

        // MARK: - Type (linked-list type surface: Linked + Bounded/Inline/Small + errors + iteration witnesses)
        .target(
            name: "List Linked Primitive",
            dependencies: [
                .product(name: "List Primitives Core", package: "swift-list-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(name: "Buffer Linked Primitive", package: "swift-buffer-linked-primitives"),
                .product(name: "Buffer Linked Primitives", package: "swift-buffer-linked-primitives"),
                .product(name: "Buffer Linked Small Primitive", package: "swift-buffer-linked-primitives"),
                .product(name: "Buffer Linked Inline Primitives", package: "swift-buffer-linked-primitives"),
                .product(name: "Iterator Primitive", package: "swift-iterator-primitives"),
                .product(name: "Iterator Protocol", package: "swift-iterator-primitives"),
                .product(name: "Iterable", package: "swift-iterator-primitives"),
                .product(name: "Iterator Chunk Primitives", package: "swift-iterator-primitives"),
                .product(name: "Storage Contiguous Primitives", package: "swift-storage-primitives"),
                .product(name: "Memory Heap Primitives", package: "swift-memory-heap-primitives"),
            ]
        ),

        // MARK: - Linked (operations / conformances over the linked-list types; doubles as umbrella)
        .target(
            name: "List Linked Primitives",
            dependencies: [
                "List Linked Primitive",
                .product(name: "List Primitives Core", package: "swift-list-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(name: "Buffer Linked Primitive", package: "swift-buffer-linked-primitives"),
                .product(name: "Buffer Linked Primitives", package: "swift-buffer-linked-primitives"),
                .product(name: "Buffer Linked Small Primitive", package: "swift-buffer-linked-primitives"),
                .product(name: "Buffer Linked Inline Primitives", package: "swift-buffer-linked-primitives"),
                .product(name: "Iterator Primitive", package: "swift-iterator-primitives"),
                .product(name: "Iterator Protocol", package: "swift-iterator-primitives"),
                .product(name: "Iterable", package: "swift-iterator-primitives"),
                .product(name: "Iterator Chunk Primitives", package: "swift-iterator-primitives"),
                .product(name: "Sequence Primitives", package: "swift-sequence-primitives"),
                .product(name: "Property Primitives", package: "swift-property-primitives"),
            ]
        ),

        // MARK: - Test Support
        .target(
            name: "List Linked Primitives Test Support",
            dependencies: [
                "List Linked Primitives",
                .product(name: "Buffer Primitives Test Support", package: "swift-buffer-primitives"),
                .product(name: "Index Primitives Test Support", package: "swift-index-primitives"),
            ],
            path: "Tests/Support"
        ),

        // MARK: - Tests
        .testTarget(
            name: "List Linked Primitives Tests",
            dependencies: [
                "List Linked Primitives",
                "List Linked Primitives Test Support",
                .product(name: "Iterable", package: "swift-iterator-primitives"),
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = [
        .enableExperimentalFeature("RawLayout"),
    ]

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
