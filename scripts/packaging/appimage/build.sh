#!/usr/bin/env bash

set -e
set -o pipefail

script_dir="$(dirname "$(readlink -f "${0}")")"

mkdir -p "${script_dir}/apidash.AppDir/app"
cp -r "${linux_folder}"/release_build/apidash/* "${script_dir}/apidash.AppDir/app/"
cp -r "${linux_folder}"/release_build/icons/hicolor/256x256/apps/apidash.png "${script_dir}/apidash.AppDir/apidash.png"
cp -r "${linux_folder}"/release_build/icons/hicolor/256x256/apps/apidash.png "${script_dir}/apidash.AppDir/.DirIcon"
cp -r "${linux_folder}"/release_build/applications/apidash.desktop "${script_dir}/apidash.AppDir/apidash.desktop"

# appimagetool doesn't like version field in a .desktop file as well as wants only one "category"
sed -i '/^Version=/d' "${script_dir}/apidash.AppDir/apidash.desktop"
sed -i 's/Categories=.*/Categories=Development/' "${script_dir}/apidash.AppDir/apidash.desktop"

cat <<EOF >"${script_dir}"/apidash.AppDir/AppRun
#!/bin/sh
HERE="\$(dirname "\$(readlink -f "\${0}")")"
EXEC="\${HERE}/app/apidash"

exec "\${EXEC}"
EOF
chmod +x "${script_dir}/apidash.AppDir/AppRun"

# Build step
appimagetool "${script_dir}"/apidash.AppDir

mkdir -p "$linux_folder/appimage"
cp ./API_Dash-x86_64.AppImage "$linux_folder/appimage/apidash_v${version}_linux.AppImage"

# Clean up
rm -rf "${script_dir}/apidash.AppDir"
rm -f ./API_Dash-x86_64.AppImage
