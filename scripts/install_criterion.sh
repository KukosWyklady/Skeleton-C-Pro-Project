#!/bin/bash

# submodule: https://github.com/Snaipe/Criterion

# Full script path
script_path=`readlink -f "${BASH_SOURCE[0]}" 2>/dev/null||echo $0`

# This directory path
script_dir=`dirname "${script_path}"`

criterion_dest_dir="${script_dir}/../libs/criterion"
mkdir -p ${criterion_dest_dir}
criterion_dir="${script_dir}/../submodules/criterion"

cd ${criterion_dir}
meson build
DESTDIR=${criterion_dest_dir} meson install -C build
rm -rf build