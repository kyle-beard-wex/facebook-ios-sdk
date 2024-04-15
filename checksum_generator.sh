
#!/bin/bash

# Define variables
declare -a prefixes=("FBAEMKit" "FBSDKCoreKit_Basics" "FBSDKCoreKit" "FBSDKLoginKit" "FBSDKShareKit" "FBSDKGamingServicesKit")

# 1. Download using wget (installed from homebrew) since curl bypasses Netskope
for prefix in "${prefixes[@]}"
do
    url="https://github.com/facebook/facebook-ios-sdk/releases/download/v17.0.0/${prefix}-Dynamic_XCFramework.zip"
    wget "https://github.com/facebook/facebook-ios-sdk/releases/download/v17.0.0/${prefix}-Dynamic_XCFramework.zip"
done

# 2. Print checksum of each downloaded file
for prefix in "${prefixes[@]}"
do
    shasum -a 256 ${prefix}-Dynamic_XCFramework.zip
done

# 3. Delete file since we no longer need
for prefix in "${prefixes[@]}"
do
    rm -f ${prefix}-Dynamic_XCFramework.zip
done

echo "All downloads completed."
