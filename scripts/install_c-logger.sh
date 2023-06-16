#!/bin/bash

# Submodule: https://github.com/yksz/c-logger

# Full script path
script_path=`readlink -f "${BASH_SOURCE[0]}" 2>/dev/null||echo $0`

# This directory path
script_dir=`dirname "${script_path}"`

clogger_dest_dir="${script_dir}/../libs/c-logger"
mkdir -p ${clogger_dest_dir}
clogger_dir="${script_dir}/../submodules/c-logger"

cd ${clogger_dir}
mkdir -p build
cmake -DCMAKE_BUILD_TYPE=Release -S . -B build -DCMAKE_INSTALL_PREFIX=${clogger_dest_dir}
cmake --build build
cmake --install build --prefix=${clogger_dest_dir}
rm -rf build