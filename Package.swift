// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "AnyLanguageModel",
    platforms: [
        .macOS(.v14),
        .macCatalyst(.v17),
        .iOS(.v17),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1),
    ],

    products: [
        .library(
            name: "AnyLanguageModel",
            targets: ["AnyLanguageModel"]
        )
    ],
    traits: [
        .trait(name: "CoreML"),
        .trait(name: "MLX"),
        .trait(name: "Llama"),
        .trait(name: "AsyncHTTPClient"),
        .default(enabledTraits: []),
    ],
    dependencies: [
        // downstream(grio): swift-transformers repointed at the SpiraMira fork carrying
        // the Core ML generation cancellation fix (#364) plus the `StoppingCriteria` +
        // `EosTokenCriteria` feature (drop before upstream merge). Revision-pinned to the
        // fork's `integration` branch (upstream 1.3.3 + fix + feature); no tag carries this
        // API, and GrioKit pins the same revision (one URL per package identity).
        .package(url: "https://github.com/SpiraMira/swift-transformers", revision: "76f92d561530f7edb48e8432159be06ae3f697f6"),
        .package(url: "https://github.com/huggingface/swift-huggingface", from: "0.9.0"),
        .package(
            url: "https://github.com/mattt/EventSource",
            from: "1.3.0",
            traits: [
                .defaults,
                .trait(name: "AsyncHTTPClient", condition: .when(traits: ["AsyncHTTPClient"])),
            ]
        ),
        .package(url: "https://github.com/mattt/JSONSchema", from: "1.3.0"),
        .package(url: "https://github.com/mattt/llama.swift", .upToNextMajor(from: "2.7484.0")),
        .package(url: "https://github.com/mattt/PartialJSONDecoder", from: "1.0.0"),
        // DOWNSTREAM-ONLY (GrioKit integration; NOT for upstream PR): point mlx-swift-lm at the
        // SpiraMira fork — 3.x line = canonical ml-explore 3.31.4 + the cancellation-submission-race
        // fix (#382) — so the identity resolves to a single URL when GrioKit also pins the fork.
        // Revision-pinned to the fork's `integration` branch. Upstream should keep
        // ml-explore/mlx-swift-lm >= 3.0.0.
        .package(url: "https://github.com/SpiraMira/mlx-swift-lm", revision: "2f93db5bb708d253d853fba992e5a463f11cc0bf"),
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "602.0.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.24.0"),
    ],
    targets: [
        .target(
            name: "AnyLanguageModel",
            dependencies: [
                .target(name: "AnyLanguageModelMacros"),
                .product(name: "EventSource", package: "EventSource"),
                .product(name: "JSONSchema", package: "JSONSchema"),
                .product(name: "PartialJSONDecoder", package: "PartialJSONDecoder"),
                .product(
                    name: "MLXLLM",
                    package: "mlx-swift-lm",
                    condition: .when(traits: ["MLX"])
                ),
                .product(
                    name: "MLXVLM",
                    package: "mlx-swift-lm",
                    condition: .when(traits: ["MLX"])
                ),
                .product(
                    name: "MLXLMCommon",
                    package: "mlx-swift-lm",
                    condition: .when(traits: ["MLX"])
                ),
                .product(
                    name: "MLXHuggingFace",
                    package: "mlx-swift-lm",
                    condition: .when(traits: ["MLX"])
                ),
                .product(
                    name: "HuggingFace",
                    package: "swift-huggingface",
                    condition: .when(traits: ["MLX"])
                ),
                .product(
                    name: "Tokenizers",
                    package: "swift-transformers",
                    condition: .when(traits: ["MLX"])
                ),
                .product(
                    name: "Transformers",
                    package: "swift-transformers",
                    condition: .when(traits: ["CoreML"])
                ),
                .product(
                    name: "LlamaSwift",
                    package: "llama.swift",
                    condition: .when(traits: ["Llama"])
                ),
                .product(
                    name: "AsyncHTTPClient",
                    package: "async-http-client",
                    condition: .when(traits: ["AsyncHTTPClient"])
                ),
            ]
        ),
        .macro(
            name: "AnyLanguageModelMacros",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "AnyLanguageModelTests",
            dependencies: [
                "AnyLanguageModel",
                .product(
                    name: "AsyncHTTPClient",
                    package: "async-http-client",
                    condition: .when(traits: ["AsyncHTTPClient"])
                ),
            ],
        ),
    ]
)
