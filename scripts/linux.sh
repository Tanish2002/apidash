#!/usr/bin/env bash

set -e
set -o pipefail

script_dir="$(dirname "$(readlink -f "${0}")")"

_build_raw() {
	echo "BUILDING A RAW LINUX APP USING FLUTTER BUILD:"
	flutter build linux --release

	echo "LINUX APP BUILT SUCCESSFULLY"

	# copy build linux_folder to the release destination
	folder="$linux_folder/release_build"
	mkdir -p "$folder/apidash"
	rm -rf "${folder:?}/*"
	cp -r build/linux/x64/release/bundle/* "$folder/apidash"
	cp -r "scripts/packaging/common/applications" "$linux_folder/release_build/"
	cp -r "scripts/packaging/common/icons" "$linux_folder/release_build/"

	# https://github.com/flutter/flutter/issues/65400
	# https://github.com/leanflutter/flutter_distributor/pull/110
	# test this out extensively to figure out if I really need this or not..
	#
	# for file in "$folder/apidash/lib"/*; do
	#   patchelf --set-rpath '$ORIGIN' "$file"
	# done

}

raw() {
	pushd "$linux_folder/release_build" >/dev/null
	echo "COMPRESSING BUILD INTO A TARBALL:"
	mkdir -p "../raw"
	tar -czvf "../raw/apidash_x64-linux.tar.gz" ./* | sed -e 's/^/>> /;'
	popd >/dev/null
}

deb() {
	echo "BUILDING DEB:"
	"${script_dir}"/packaging/deb/build.sh | sed -e 's/^/>> /;'
	echo "BUILT DEB SUCCESSFULLY"
}

rpm() {
	echo "BUILDING RPM:"
	raw # RPM Build depends on the tarball
	"${script_dir}"/packaging/rpm/build.sh | sed -e 's/^/>> /;'
	echo "BUILT DEB SUCCESSFULLY"
}

rpm() {
	echo "BUILDING RPM:"
	raw # RPM Build depends on the tarball
	"${script_dir}"/packaging/rpm/build.sh | sed -e 's/^/>> /;'
	echo "BUILT RPM SUCCESSFULLY"
}

appimage() {
	echo "BUILDING APPIMAGE:"
	"${script_dir}"/packaging/appimage/build.sh | sed -e 's/^/>> /;'
	echo "BUILT APPIMAGE SUCCESSFULLY"
}

flatpak() {
	echo "BUILDING FLATPAK:"

	# ./build.sh | sed -e 's/^/>> /;'

	echo "BUILT FLATPAK SUCCESSFULLY"
}

packaging=(raw deb rpm appimage flatpak snap)
echo "Chose your Packaging type ${packaging[*]}: "
read -r package

export linux_folder="${build_folder}/linux"
_build_raw

if [ "$package" = "raw" ]; then
	raw
elif [ "$package" = "deb" ]; then
	deb
elif [ "$package" = "appimage" ]; then
	appimage
elif [ "$package" = "flatpak" ]; then
	flatpak
elif [ "$package" = "rpm" ]; then
	rpm
fi
