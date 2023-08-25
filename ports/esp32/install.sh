#!/bin/bash

sudo apt-get install coreutils

git submodule update --init ../../lib/berkeley-db-1.xx
git submodule update --init ../../lib/micropython-lib