#!/bin/bash

set -e

# Ensure a version number is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <version>"
  exit 1
fi

VERSION=$1

# Validate the version format
if [[ ! $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9]+)?$ ]]; then
  echo "Version must be in the format x.x.x or x.x.x-tag (e.g., 1.0.0 or 1.0.0-beta)"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PODSPEC_PATH="$SCRIPT_DIR/DaroAds.podspec"

# Update version in podspec file
sed -i '' "s/spec\.version = '[^']*'/spec.version = '$VERSION'/" "$PODSPEC_PATH"

# Commit and push the changes
git add .
git commit -m "Bump version to $VERSION"
git push origin main

git tag $VERSION
git push origin $VERSION

# Check if Daro.xcframework.zip exists
if [ ! -f "$SCRIPT_DIR/build/Daro.xcframework.zip" ]; then
  echo "$SCRIPT_DIR/build/Daro.xcframework.zip file not found"
  exit 1
fi

# # Create a tag and release using GitHub CLI with the file
gh release create $VERSION "$SCRIPT_DIR/build/Daro.xcframework.zip" --title "Release $VERSION" --notes "Release version $VERSION"
git pull origin main

# # Push the podspec to the trunk
pod trunk push "$PODSPEC_PATH" --allow-warnings --verbose
