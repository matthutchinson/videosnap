#!/bin/zsh

# pkgAndNotarize.sh

# 2019 - Armin Briegel - Scripting OS X

# place a copy of this script in in the project folder
# when run it will build for installation,
# create a pkg from the product,
# upload the pkg for notarization and monitor the notarization status

# before you can run this script:
# - set release signing of the tool to 'Developer ID Application'
# - enable the hardened run-time
# - change the 'Installation Build Products Location' to `$SRCROOT/build/pkgroot`
#
# you want to add the `build` subdirectory to gitignore

# put your dev account information into these variables

# the email address of your developer account
dev_account="matt@hiddenloop.com"

# the name of your Developer ID installer certificate
signature="Developer ID Installer: Hiddenloop Ltd. (8VF6UH3LYN)"

# the 10-digit team id
dev_team="8VF6UH3LYN"

# the label of the keychain item which contains an app-specific password
dev_keychain_label="Developer-altool"

# put your project's information into these variables
version="0.0.7"
identifier="com.hiddenloop.videosnap"
productname="videosnap"

# code starts here
projectdir=$(dirname $0)
builddir="$projectdir/build"
pkgroot="$builddir/pkgroot"

# functions
requeststatus() { # $1: requestUUID
    requestUUID=${1?:"need a request UUID"}
    req_status=$(xcrun altool --notarization-info "$requestUUID" \
                              --username "$dev_account" \
                              --password "@keychain:$dev_keychain_label" 2>&1 \
                 | awk -F ': ' '/Status:/ { print $2; }' )
    echo "$req_status"
}

notarizefile() { # $1: path to file to notarize, $2: identifier
    filepath=${1:?"need a filepath"}
    identifier=${2:?"need an identifier"}

    # upload file
    echo "## uploading $filepath for notarization"
    requestUUID=$(xcrun altool --notarize-app \
                               --primary-bundle-id "$identifier" \
                               --username "$dev_account" \
                               --password "@keychain:$dev_keychain_label" \
                               --asc-provider "$dev_team" \
                               --file "$filepath" 2>&1 \
                  | awk '/RequestUUID/ { print $NF; }')

    echo "Notarization RequestUUID: $requestUUID"

    if [[ $requestUUID == "" ]]; then
        echo "could not upload for notarization"
        exit 1
    fi

    # wait for status to be not "in progress" any more
    request_status="in progress"
    while [[ "$request_status" == "in progress" ]]; do
        echo -n "waiting... "
        sleep 10
        request_status=$(requeststatus "$requestUUID")
        echo "$request_status"
    done

    # print status information
    xcrun altool --notarization-info "$requestUUID" \
                 --username "$dev_account" \
                 --password "@keychain:$dev_keychain_label"
    echo

    if [[ $request_status != "success" ]]; then
        echo "## could not notarize $filepath"
        exit 1
    fi

}


# build clean install

echo "## building with Xcode"
xcodebuild clean install -quiet


# check if pkgroot exists where we expect it
if [[ ! -d $pkgroot ]]; then
    echo "couldn't find pkgroot $pkgroot"
    exit 1
fi

# copy man page asset to a bundled share folder
echo "## copying man page: $pkgroot/usr/local/share/man/man1/"
mkdir -p "$pkgroot/usr/local/share"
mkdir -p "$pkgroot/usr/local/share/man"
mkdir -p "$pkgroot/usr/local/share/man/man1"
cp "$productname/videosnap.1" "$pkgroot/usr/local/share/man/man1/videosnap.1"

## build the pkg
pkgpath="$builddir/$productname-$version.pkg"

echo "## building pkg: $pkgpath"
pkgbuild --root "$pkgroot" \
         --version "$version" \
         --identifier "$identifier" \
         --sign "$signature" \
         "$pkgpath"

# upload for notarization
notarizefile "$pkgpath" "$identifier"

# staple result
echo "## Stapling $pkgpath"
xcrun stapler staple "$pkgpath"

echo '## Done!'

# show the pkg in Finder
open -R "$pkgpath"

exit 0
