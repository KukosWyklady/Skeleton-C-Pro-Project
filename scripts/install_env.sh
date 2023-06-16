#!/bin/bash

# hashMap with key = os specific file, value = command to install
declare -A osInfo;
osInfo[/etc/debian_version]="sudo apt-get install -y"
osInfo[/etc/centos-release]="sudo yum install -y"
osInfo[/etc/fedora-release]="sudo dnf install -y"

install_command=""
for f in ${!osInfo[@]}
do
    if [[ -f $f ]]; then
        install_command=${osInfo[$f]}
        break
    fi
done

if [[ -z "${install_command}" ]]; then
    exit 1
fi

packages=("gcc" "clang" "make" "valgrind" "clang-tools" "git" "ninja-build" "pkg-config" \
          "python3" "python3-pip" "python3-setuptools" "python3-wheel")

for p in ${packages[@]}
do
   cmd="${install_command} ${p}" || exit 1
   eval ${cmd}
done

# OS specific package: DEBIAN
if [[ -f "/etc/debian_version" ]]; then
    sudo apt-get install -y libffi-dev || exit 1
    sudo apt-get install -y libgit2-dev || exit 1
elif [[ -f "/etc/centos-release" ]]; then
    sudo yum install -y libffi-devel || exit 1
    sudo yum install -y libgit2-devel || exit 1
elif [[ -f "/etc/fedora-release" ]]; then
    sudo dnf install -y libffi-devel || exit 1
    sudo dnf install -y libgit2-devel || exit 1
fi

# Python (pip)
sudo pip3 install --prefix=/usr/bin meson || exit 1