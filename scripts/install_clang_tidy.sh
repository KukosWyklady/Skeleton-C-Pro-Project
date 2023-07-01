#!/bin/bash

# ALIGN version of clang tidy with github actions, for now it is 14
VERSION=14

installed_version=`clang-tidy --version | head -n 1 | awk '{print $4}' | awk -F . '{print $1}'`
if [[ ${installed_version} -ge ${VERSION} ]]; then
    echo "clang-tidy in version ${installed_version}, required ${VERSION}, nothing to do"
    exit 0
fi

wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
sudo ./llvm.sh ${VERSION}

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

cmd="${install_command} clang-tidy-${VERSION}" || exit 1
eval ${cmd}
sudo ln -s /bin/clang-tidy-${VERSION} /bin/clang-tidy

rm -rf llvm.sh