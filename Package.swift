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
    static let basics = library(name: .basics, targets: [.Prefixed.basics])
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
        "https://github.com/facebook/facebook-ios-sdk/releases/download/v16.1.2/\(targetName)-Static_XCFramework.zip"
    }
    
    static let aem = target(name: .aem, dependencies: [.Prefixed.aem])

    static let core = target(
        name: .core,
        dependencies: [.aem, .Prefixed.basics, .Prefixed.core],
        linkerSettings: [
            .cPlusPlusLibrary,
            .zLibrary,
            .accelerateFramework,
        ]
    )

    static let login = target(name: .login, dependencies: [.core, .Prefixed.login])

    static let share = target(name: .share, dependencies: [.core, .Prefixed.share])

    static let gaming = target(name: .gaming, dependencies: [.Prefixed.gaming])

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
        static let aem = "d45388a46c0ac2e89c277136c6cc63137864b90022d2e785beb979ec09a8f70c"
        static let basics = "af64aad14fa8b0486ccb9f1483fe782e06acbe3309ff0c4143994bfc5ad62e6c"
        static let core = "2c5c1c3532f357d2a0e89035d8a41421709cacbe505cbc25880960d6f5907170"
        static let login = "9bd091a4accb23a143f6de71f0267279616287fa931138766723471242606bf8"
        static let share = "1dd3dd20ed42d651b992b9b1b71742c9e90630085f22f683d220bc64fca5321e"
        static let gaming = "fd6bb813cae23716afbc6f5f0c229bb5847b15bc3b6c50448b7b340b07213469"
    }
    
    /// This corresponds to the checksum that everyone else more fortunate to not encounter Netskope would see.
    enum RemoteChecksum {
        static let aem = "8e9e1ef0aadbbd3e140822b0fc3313b011bb959c7cdad5f1c1745dd4e96d8c4c"
        static let basics = "ba2fab4ac759fcb4aba48c25f1222c0839c697d7cb7de4a5e28befe26b0b3caa"
        static let core = "6fecfd2342d00a8020bc371b00b25cdd020acebed5ab20ef796c81d52fbcad22"
        static let login = "d98bd590683281d5c8c3ea900047c3586126465d34c3dc264b8d51c01019a328"
        static let share = "42d7dce3155e3c9c9a7db29789e3606757ad7b29a4f7ad9da77afbbe9bc41bd3"
        static let gaming = "91f7433eadf3257cf0ff2a80e3364d52dd5b542c72876f6cdc1e1f7a6aec556f"
    }
}
