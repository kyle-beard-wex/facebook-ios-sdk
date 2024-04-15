
#!/bin/bash

# Define variables
declare -a prefixes=("FBAEMKit" "FBSDKCoreKit_Basics" "FBSDKCoreKit" "FBSDKLoginKit" "FBSDKShareKit" "FBSDKGamingServicesKit")

# Below was a work in progress to print the physical code block
declare -A prefixMap
prefixMap["aem"]="FBAEMKit"
prefixMap["basics"]="FBSDKCoreKit_Basics"
prefixMap["core"]="FBSDKCoreKit"
prefixMap["login"]="FBSDKLoginKit"
prefixMap["share"]="FBSDKShareKit"
prefixMap["gaming"]="FBSDKGamingServicesKit"

# 1. Download using wget (installed from homebrew) since curl bypasses Netskope
for prefix in "${prefixes[@]}"
do
    wget "https://github.com/facebook/facebook-ios-sdk/releases/download/v17.0.0/${prefix}-Dynamic_XCFramework.zip"
done

# 2. Print checksum of each downloaded file
echo "LocalChecksum:"
for prefix in "${prefixes[@]}"
do
shasum -a 256 ${prefix}-Dynamic_XCFramework.zip
done

# 3. Delete file since we no longer need
for prefix in "${prefixes[@]}"
do
    rm -f ${prefix}-Dynamic_XCFramework.zip
done

# 4. Download using curl (installed from homebrew) since curl bypasses Netskope
for prefix in "${prefixes[@]}"
do
    curl -LOs "https://github.com/facebook/facebook-ios-sdk/releases/download/v17.0.0/${prefix}-Dynamic_XCFramework.zip"
done

# 5. Print checksum of each downloaded file
echo ""
echo "RemoteChecksum:"
for prefix in "${prefixes[@]}"
do
shasum -a 256 ${prefix}-Dynamic_XCFramework.zip
done

# 6. Delete file since we no longer need (again)
for prefix in "${prefixes[@]}"
do
    rm -f ${prefix}-Dynamic_XCFramework.zip
done

echo "All downloads completed."
