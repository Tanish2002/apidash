#!/usr/bin/env bash

set -e
set -o pipefail

script_dir="$(dirname "$(readlink -f "${0}")")"
mkdir -p "${script_dir}"/apidash/usr/share/apidash
mkdir -p "${script_dir}"/apidash/DEBIAN
cp -r "${linux_folder}"/release_build/* "${script_dir}"/apidash/usr/share/

# debian control file
cat <<EOF >"${script_dir}"/apidash/DEBIAN/control
Maintainer: Ashita Prasad <ashita@xyz.com>
Package: apidash
Version: ${version}
Section: x11
Priority: optional
Architecture: amd64
Essential: no
Installed-Size: 15700
Description: API Dash is a beautiful open-source cross-platform API Client built using Flutter which can help you easily create & customize your API requests, visually inspect responses and generate Dart code on the go.
Depends: mpv
EOF

cat <<EOF >"${script_dir}"/apidash/DEBIAN/postinst
#!/bin/sh
ln -s /usr/share/apidash/apidash /usr/bin/apidash
chmod +x /usr/bin/apidash
exit 0
EOF

cat <<EOF >"${script_dir}"/apidash/DEBIAN/postrm
#!/bin/sh
rm /usr/bin/apidash
exit 0
EOF

chmod +x "${script_dir}"/apidash/DEBIAN/postinst
chmod +x "${script_dir}"/apidash/DEBIAN/postrm

# Build the deb
dpkg-deb --build "${script_dir}"/apidash

mkdir -p "$linux_folder"/deb
cp "${script_dir}"/apidash.deb "$linux_folder"/deb/apidash_v"${version}"_linux.deb

# Clean up
rm -rf "${script_dir}"/apidash
rm -rf "${script_dir}"/apidash.deb
