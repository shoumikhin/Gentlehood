#!/usr/bin/env bash

set -e

die()
{
    if [ $# -eq 0 ]; then
        msg="\n** FAILED **\n"
    else
        msg="$@"
    fi

    echo -e "$msg" >&2

    exit
}

succeeded()
{
    echo -e "** SUCCEEDED **"
}

[ $# -ge 1 ] || die "Usage: $0 <build_number>"

BUILD_NUMBER=$1
PROJECT_NAME="Gentlehood"
PROJECT_DIR="`pwd`"
BUILD_DIR="$PROJECT_DIR/DerivedData"
PRODUCTS_DIR="$BUILD_DIR/$PROJECT_NAME/Build/Products"
OUTPUT_DIR="$PROJECT_DIR/Deliverables"
RELEASE="Release"
DEBUG="Debug"
IPHONEOS="iphoneos"
IPHONESIMULATOR="iphonesimulator"

rm -rf "$BUILD_DIR" || die
rm -rf "$OUTPUT_DIR" || die
mkdir -p "$OUTPUT_DIR" || die

build()
{
    SCHEME="$1"
    CONFIG="$2"
    OUTPUT_FILE="$OUTPUT_DIR/Build_${CONFIG}_${BUILD_NUMBER}.txt"

    xcodebuild -workspace "$PROJECT_NAME.xcworkspace" -scheme "$SCHEME" -configuration "$CONFIG" -sdk "$IPHONEOS" clean build > "$OUTPUT_FILE" || die
}

package()
{
    cp -r "$PRODUCTS_DIR/${RELEASE}-${IPHONEOS}/${PROJECT_NAME}.app" "$OUTPUT_DIR" || die
    xcrun -sdk iphoneos PackageApplication -v "$OUTPUT_DIR/${PROJECT_NAME}.app" -o "$OUTPUT_DIR/${PROJECT_NAME}.ipa" >/dev/null || die
    ./build_manifest.py -f "$OUTPUT_DIR/${PROJECT_NAME}.app" -d "$OUTPUT_DIR/${PROJECT_NAME}.ipa.plist" -a "" -c "manifest_log.txt" -i  "$OUTPUT_DIR/${PROJECT_NAME}.ipa" || die
    rm -rf "$OUTPUT_DIR/${PROJECT_NAME}.app"
}

echo -e "\n** BUILDING **"

build "$PROJECT_NAME" "$RELEASE" && succeeded

echo -e "\n** PACKING **"

package && succeeded
