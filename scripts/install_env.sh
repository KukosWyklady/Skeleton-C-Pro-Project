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

packages=("gcc" "clang" "make" "valgrind" "clang-tools", "git")

for p in ${packages[@]}
do
   cmd="${install_command} ${p}"
   eval ${cmd}
done