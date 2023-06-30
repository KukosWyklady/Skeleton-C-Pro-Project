#!/bin/bash

# Install at least 3.20 valgrind to support Dwarf5

git clone https://sourceware.org/git/valgrind.git
cd valgrind
./autogen.sh
./configure
make -j 4
sudo make install
cd ..
rm -rf valgrind