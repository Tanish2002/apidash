#!/usr/bin/env bash

set -e
set -o pipefail

script_dir="$(dirname "$(readlink -f "${0}")")"

echo "$script_dir"

mkdir -p "${script_dir}"/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

cp -r "${linux_folder}"/raw/* "${script_dir}/rpmbuild/SOURCES/"

cat <<EOF >"${script_dir}"/rpmbuild/SPECS/apidash.spec
Name:          apidash
Version:       ${version}
Release:       1%{?dist}
Summary:       Cross-Platform API Client
BuildArch:     x86_64
URL:           https://github.com/foss42/apidash
License:       Apache-2.0
Requires: mpv
Source0:       %{name}_x64-linux.tar.gz

%description
A beautiful open-source cross-platform API Client built using Flutter

%prep
%setup -q -c

%install
mkdir -p "%{buildroot}/usr/lib/%{name}" && cp -r %{name}/* -t "%{buildroot}/usr/lib/%{name}"
mkdir -p "%{buildroot}/usr/bin"
install -Dm 644 applications/%{name}.desktop -t "%{buildroot}/usr/share/%{name}/files"
install -Dm 644 icons/hicolor/128x128/apps/%{name}.png "%{buildroot}/usr/share/icons/hicolor/128x128/apps/%{name}.png"
install -Dm 644 icons/hicolor/256x256/apps/%{name}.png "%{buildroot}/usr/share/icons/hicolor/256x256/apps/%{name}.png"

%files
/usr/lib/%{name}/*
/usr/share/icons/hicolor/128x128/apps/%{name}.png
/usr/share/icons/hicolor/256x256/apps/%{name}.png
/usr/share/%{name}/files/%{name}.desktop

%post
cp /usr/share/%{name}/files/%{name}.desktop /usr/share/applications/
ln -s /usr/lib/%{name}/%{name} /usr/bin/%{name}

%postun
case "$1" in
  0)
    # for uninstall
    rm /usr/share/applications/%{name}.desktop || true
    rm /usr/bin/%{name} || true
    update-desktop-database
  ;;
  1)
    # for upgrade
  ;;
esac
EOF

# Build the rpm
rpmbuild -bb --define "_topdir ${script_dir}/rpmbuild" "${script_dir}"/rpmbuild/SPECS/apidash.spec

mkdir -p "$linux_folder"/rpm
cp "${script_dir}"/rpmbuild/RPMS/x86_64/*.rpm "$linux_folder"/rpm/apidash_"${version}".x86_64.rpm

# Clean up
rm -rf "${script_dir}"/rpmbuild
