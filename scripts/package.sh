#!/usr/bin/env bash

set -e
set -o pipefail

platforms=(linux win macos)
export build_folder="releases"

# WORKING DIR
if [ -f "../pubspec.yaml" ]; then
	cd ..
elif [ ! -f "pubspec.yaml" ]; then
	echo "unable to locate project folder" >&2
	exit 1
fi

# Create build folder if not found
[ ! -f "${build_folder}" ] && mkdir -p $build_folder

# VERSION
version="$(yq -r '.version' pubspec.yaml | cut -d'+' -f1)"
export version

# PLATFORM
while true; do
	echo "Available platforms: ${platforms[*]}"
	echo "Enter desired platform: "
	read -r platform

	if [[ ${platforms[*]} =~ $platform ]]; then
		break # Valid platform selected, exit loop
	else
		echo "Invalid platform. Please try again."
	fi
done

echo "RUNNING FLUTTER CLEAN:"
flutter clean | sed -e 's/^/>> /;'

# Modular Platform Builds
export platform=$platform
if [ "$platform" = "linux" ]; then
	./scripts/linux.sh
fi
