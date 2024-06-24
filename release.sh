#!/bin/bash

# Ensure a version number is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <version>"
  exit 1
fi

VERSION=$1

# Validate the version format
if [[ ! $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Version must be in the format x.x.x"
  exit 1
fi

# Validate the version number in DaroAds.podspec
if ! grep -q "spec.version *= *'$VERSION'" DaroAds.podspec; then
  echo "Version $VERSION does not match the version in DaroAds.podspec"
  exit 1
fi

# Check if Daro.xcframework.zip exists
if [ ! -f "Daro.xcframework.zip" ]; then
  echo "Daro.xcframework.zip file not found"
  exit 1
fi

# Create a tag and release using GitHub CLI with the file
gh release create $VERSION "Daro.xcframework.zip" --title "Release $VERSION" --notes "Release version $VERSION"

# Push the podspec to the trunk
pod trunk push DaroAds.podspec --allow-warnings --verbose