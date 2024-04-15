// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the
 * LICENSE file in the root directory of this source tree.
 */

import PackageDescription
import Foundation

#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

let package = Package(
    name: "Facebook",
    platforms: [.iOS(.v12)],
    products: [
        // The Kernel of the SDK. Must be included as a runtime dependency.
        .basics,

        // The Facebook AEM Kit
        .aem,

        /*
          The Core SDK library that provides two importable modules:

            - FacebookCore which includes the most current interface and
              will contain interfaces for new features written in Swift

            - FBSDKCoreKit which contains legacy Objective-C interfaces
              that will be used to maintain backwards compatibility with
              types that have been converted to Swift.
              This will not contain interfaces for new features written in Swift.
         */
        .core,

        // The Facebook Login SDK
        .login,

        // The Facebook Share SDK
        .share,

        // The Facebook Gaming Services SDK
        .gaming,
    ],
    targets: [
        // The kernel of the SDK
        .Prefixed.basics,
        .basics,

        /*
          The legacy Objective-C implementation that will be converted to Swift.
          This will not contain interfaces for new features written in Swift.
        */
        .Prefixed.aem,

        // The main AEM module
        .aem,

        /*
          The legacy Objective-C implementation that will be converted to Swift.
          This will not contain interfaces for new features written in Swift.
        */
        .Prefixed.core,

        // The main Core SDK module
        .core,

        /*
          The legacy Objective-C implementation that will be converted to Swift.
          This will not contain interfaces for new features written in Swift.
        */
        .Prefixed.login,

        // The main Login SDK module
        .login,

        /*
          The legacy Objective-C implementation that has been converted to Swift.
          This will not contain interfaces for new features written in Swift.
        */
        .Prefixed.share,

        // The main Share SDK module
        .share,

        /*
          The legacy Objective-C implementation that has been converted to Swift.
          This will not contain interfaces for new features written in Swift.
        */
        .Prefixed.gamingServices,

        // The main Facebook Gaming Services module
        .gaming,
    ],
    cxxLanguageStandard: .cxx11
)

extension Product {
    static let basics = library(name: .basics, targets: [.basics, .Prefixed.basics])
    static let core = library(name: .core, targets: [.core, .Prefixed.core])
    static let login = library(name: .login, targets: [.login])
    static let share = library(name: .share, targets: [.share, .Prefixed.share])
    static let gaming = library(name: .gaming, targets: [.gaming, .Prefixed.gaming])
    static let aem = library(name: .aem, targets: [.aem, .Prefixed.aem])
}

extension Target {
    static let binarySource = BinarySource()

    static func binaryTarget(name: String, remoteChecksum: String) -> Target {
        return .binaryTarget(name: name, url: remoteBinaryURLString(for: name), checksum: remoteChecksum)
    }

    static func remoteBinaryURLString(for targetName: String) -> String {
        "https://github.com/facebook/facebook-ios-sdk/releases/download/v17.0.0/\(targetName)-Dynamic_XCFramework.zip"
    }

    static let basics = target(
        name: .basics,
        dependencies: [.Prefixed.basics],
        resources: [
           .copy("Resources/PrivacyInfo.xcprivacy"),
        ]
    )

    static let aem = target(
        name: .aem,
        dependencies: [.Prefixed.aem],
        resources: [
           .copy("Resources/PrivacyInfo.xcprivacy"),
        ]
    )

    static let core = target(
        name: .core,
        dependencies: [.aem, .Prefixed.basics, .Prefixed.core],
        resources: [
           .copy("Resources/PrivacyInfo.xcprivacy"),
        ],
        linkerSettings: [
            .cPlusPlusLibrary,
            .zLibrary,
            .accelerateFramework,
        ]
    )

    static let login = target(
        name: .login,
        dependencies: [.core, .Prefixed.login],
        resources: [
            .copy("Resources/PrivacyInfo.xcprivacy"),
        ]
    )

    static let share = target(
        name: .share,
        dependencies: [.core, .Prefixed.share],
        resources: [
           .copy("Resources/PrivacyInfo.xcprivacy"),
        ]
    )

    static let gaming = target(name: .gaming, dependencies: [.core, .Prefixed.share, .Prefixed.gaming])

    enum Prefixed {
        static let basics = binaryTarget(
            name: .Prefixed.basics,
            remoteChecksum: binarySource == .local ? .LocalChecksum.basics : .RemoteChecksum.basics
        )

        static let aem = binaryTarget(
            name: .Prefixed.aem,
            remoteChecksum: binarySource == .local ? .LocalChecksum.aem : .RemoteChecksum.aem
        )

        static let core = binaryTarget(
            name: .Prefixed.core,
            remoteChecksum: binarySource == .local ? .LocalChecksum.core : .RemoteChecksum.core
        )

        static let login = binaryTarget(
            name: .Prefixed.login,
            remoteChecksum: binarySource == .local ? .LocalChecksum.login : .RemoteChecksum.login
        )

        static let share = binaryTarget(
            name: .Prefixed.share,
            remoteChecksum: binarySource == .local ? .LocalChecksum.share : .RemoteChecksum.share
        )

        static let gamingServices = binaryTarget(
            name: .Prefixed.gaming,
            remoteChecksum: binarySource == .local ? .LocalChecksum.gaming : .RemoteChecksum.gaming
        )
    }
}

extension Target.Dependency {
    static let aem = byName(name: .aem)
    static let core = byName(name: .core)

    enum Prefixed {
        static let aem = byName(name: .Prefixed.aem)
        static let basics = byName(name: .Prefixed.basics)
        static let core = byName(name: .Prefixed.core)
        static let login = byName(name: .Prefixed.login)
        static let share = byName(name: .Prefixed.share)
        static let gaming = byName(name: .Prefixed.gaming)
    }
}

extension LinkerSetting {
    static let cPlusPlusLibrary = linkedLibrary("c++")
    static let zLibrary = linkedLibrary("z")
    static let accelerateFramework = linkedFramework("Accelerate")
}

enum BinarySource {
    case local, remote

    init() {
        self = getenv("IGNORE_WEX_CHECKSUM") != nil ? .remote : .local
    }
}

extension String {
    static let aem = "FacebookAEM"
    static let basics = "FacebookBasics"
    static let core = "FacebookCore"
    static let login = "FacebookLogin"
    static let share = "FacebookShare"
    static let gaming = "FacebookGamingServices"

    /// Download the .zip files with these prefixed names that correspond to the remote URL above.
    enum Prefixed {
        static let aem = "FBAEMKit"
        static let basics = "FBSDKCoreKit_Basics"
        static let core = "FBSDKCoreKit"
        static let login = "FBSDKLoginKit"
        static let share = "FBSDKShareKit"
        static let gaming = "FBSDKGamingServicesKit"
    }

    /// This checksum corresponds to the WEX Netskope fuckery that occurs when they unzip and rezip files -_-
    enum LocalChecksum {
        static let aem = "44b202760fb8d68dd63af67bb6e4fbf73b3aa8bd9852437da3a2835e55c454f0"
        static let basics = "385f54c71a1cf551c741fcb87fb87b072dbd46378af9922b207b89325a9b5969"
        static let core = "f1c454892025bb45c0e72402c8a15bbe235641c9d41cab1850c09be864e9511a"
        static let login = "971d6dc6917486fe74a8ee781d6dc534d986815f0bd5ecc907259d670cd2aed5"
        static let share = "cfdc89eab2e50a33293aeafea79ce098015d5b5e2e4b1eabb142aa488e0674d4"
        static let gaming = "83bf46b0fbbf9a665fbc349b089943017415b982e09d7cfecbfa0d3bbde626bb"
    }

    /// This corresponds to the checksum that everyone else more fortunate to not encounter Netskope would see.
    enum RemoteChecksum {
        static let aem = "6568e253756f2fa9047d59bc72b57c9737448167ab3e1cc3568a2dc08cafd9d3"
        static let basics = "033a40dc5d9e0341629a0efa09830bc061b65bb41afe2768f01ad662935f0e47"
        static let core = "d556dff856187542463a69b7b72d5cf642ca1adce2e8c2d7c3c2ab15173caafa"
        static let login = "5acf22e3e6071bc24d043cc91a84d857a866b328009aa090e09f92dbb3341880"
        static let share = "806d80c323374b25c8ad2eeedc5a82764acf842860afa5c9c6cdc0baa9d6f9c5"
        static let gaming = "5061d084c5f5f97fba33a0bbac8911cbc1e965cc05c9ea8c2fc892f739d9dd63"
    }
}
