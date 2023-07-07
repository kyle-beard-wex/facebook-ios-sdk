# Facebook SDK for iOS
This repository has been forked from https://github.com/facebook/facebook-ios-sdk 

The latest release compatible is v16.1.2. Read below for updating this repo for future necessary releases.

## Instructions
To update to a newer release, you'll need to copy over the checksums for each SDK binary for the remote `Prefixed` configuration in `Package.swift`, and then run `swift package compute-checksum <binary>.zip` on your local WEX machine to get the checksum differential that is changed when Netskope unzips and rezips the file during download for the local `Prefixed` configuration. Then, ensure the remote binary URL has the correct release version in the path. If you hit any issues, check to ensure the `IGNORE_WEX_CHECKSUM` env variable is set in the Fastfile and is being set in the pipeline, but not on your local machine.
