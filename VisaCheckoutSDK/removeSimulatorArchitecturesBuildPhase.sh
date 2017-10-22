# This script removes simulator architectures from VisaCheckoutSDK.framework so it can be uploaded to the App Store.
# Make this a Build Phase run script after the 'Embed Frameworks' phase.
# 'Run script only when installing' should be checked.
# http://stackoverflow.com/questions/30547283/submit-to-app-store-issues/30866648

APP_PATH="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"

FRAMEWORK_EXECUTABLE_NAME=VisaCheckoutSDK
find "$APP_PATH" -name "${FRAMEWORK_EXECUTABLE_NAME}.framework" -type d | while read -r FRAMEWORK
do

FRAMEWORK_EXECUTABLE_PATH="$FRAMEWORK/$FRAMEWORK_EXECUTABLE_NAME"

EXTRACTED_ARCHS=()

for ARCH in $ARCHS
do
lipo -extract "$ARCH" "$FRAMEWORK_EXECUTABLE_PATH" -o "$FRAMEWORK_EXECUTABLE_PATH-$ARCH"
EXTRACTED_ARCHS+=("$FRAMEWORK_EXECUTABLE_PATH-$ARCH")
done

lipo -o "$FRAMEWORK_EXECUTABLE_PATH-merged" -create "${EXTRACTED_ARCHS[@]}"
rm "${EXTRACTED_ARCHS[@]}"

rm "$FRAMEWORK_EXECUTABLE_PATH"
mv "$FRAMEWORK_EXECUTABLE_PATH-merged" "$FRAMEWORK_EXECUTABLE_PATH"
done