# Facebook SDK for iOS
This repository has been forked from https://github.com/facebook/facebook-ios-sdk 

Read below for updating this repo for future necessary releases.

## Instructions
The `Package.swift` file in this repository differs from the upstream Facebook SDK file as we have tweaked it to allow for both local (WEX computers) and remote (non-WEX computers like ADO) to handle different checksums depending on environment, which is checked by the environment variable `IGNORE_WEX_CHECKSUM` existing. We only set this value in the pipeline Fastfile. When wanting to pull in the latest, run the following commands:

1. If the upstream wasn't set locally yet, run `git remote add upstream https://github.com/facebook/facebook-ios-sdk` before continuing. 
2. Run `git fetch upstream && git merge upstream/main` which will pull in Facebook SDK's main branch into the local main branch of the fork. You'll have conflicts in the Package.swift file so be very cautious to cherrypick only necessary chages without disrupting this forked repo's architecture of that file. Refer to Kyle Beard on how to merge appropriately.
3. Run `bash checksum_generator.sh` to generate the prinouts for the local and remote checksums and update them appropriately in the Package file.
4. Be sure to not merge back into main, but cut a release/x.x.x branch and push up. Then tag the release so it's accessible from Swift Package Manager.
5. Once Xcode verified a successful build of the latest tagged version, you can merge that release branch into this forked repo's main branch.
