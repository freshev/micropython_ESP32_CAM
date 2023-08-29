#!/bin/bash

if which nproc > /dev/null; then
    MAKEOPTS="-j$(nproc)"
else
    MAKEOPTS="-j$(sysctl -n hw.ncpu)"
fi

########################################################################################
# general helper functions

function ci_gcc_arm_setup {
    sudo apt-get install gcc-arm-none-eabi libnewlib-arm-none-eabi
    arm-none-eabi-gcc --version
}

########################################################################################
# code formatting

function ci_code_formatting_setup {
    sudo apt-get install uncrustify
    pip3 install black
    uncrustify --version
    black --version
}

function ci_code_formatting_run {
    tools/codeformat.py -v
}

########################################################################################
# code spelling

function ci_code_spell_setup {
    pip3 install codespell tomli
}

function ci_code_spell_run {
    codespell
}

########################################################################################
# commit formatting

function ci_commit_formatting_run {
    git remote add upstream https://github.com/micropython/micropython.git
    git fetch --depth=100 upstream  master
    # For a PR, upstream/master..HEAD ends with a merge commit into master, exclude that one.
    tools/verifygitlog.py -v upstream/master..HEAD --no-merges
}

########################################################################################
# code size

function ci_code_size_setup {
    sudo apt-get update
    sudo apt-get install gcc-multilib
    gcc --version
    ci_gcc_arm_setup
}

function ci_code_size_build {
    # check the following ports for the change in their code size
    PORTS_TO_CHECK=bmusxpd
    SUBMODULES="lib/asf4 lib/berkeley-db-1.xx lib/mbedtls lib/micropython-lib lib/nxp_driver lib/pico-sdk lib/stm32lib lib/tinyusb"

    # starts off at either the ref/pull/N/merge FETCH_HEAD, or the current branch HEAD
    git checkout -b pull_request # save the current location
    git remote add upstream https://github.com/micropython/micropython.git
    git fetch --depth=100 upstream master
    # build reference, save to size0
    # ignore any errors with this build, in case master is failing
    git checkout `git merge-base --fork-point upstream/master pull_request`
    git submodule update --init $SUBMODULES
    git show -s
    tools/metrics.py clean $PORTS_TO_CHECK
    tools/metrics.py build $PORTS_TO_CHECK | tee ~/size0 || true
    # build PR/branch, save to size1
    git checkout pull_request
    git submodule update --init $SUBMODULES
    git log upstream/master..HEAD
    tools/metrics.py clean $PORTS_TO_CHECK
    tools/metrics.py build $PORTS_TO_CHECK | tee ~/size1
}

########################################################################################
# .mpy file format

function ci_mpy_format_setup {
    sudo pip3 install pyelftools
}

function ci_mpy_format_test {
    # Test mpy-tool.py dump feature on bytecode
    python2 ./tools/mpy-tool.py -xd tests/frozen/frozentest.mpy
    python3 ./tools/mpy-tool.py -xd tests/frozen/frozentest.mpy

    # Test mpy-tool.py dump feature on native code
    make -C examples/natmod/features1
    ./tools/mpy-tool.py -xd examples/natmod/features1/features1.mpy
}

########################################################################################
# ports/esp32

function ci_esp32_idf50_setup {
    pip3 install pyelftools
    git clone https://github.com/espressif/esp-idf.git
    git -C esp-idf checkout v5.0.2
    ./esp-idf/install.sh
}

function ci_esp32_build {
    source esp-idf/export.sh
    make ${MAKEOPTS} -C mpy-cross
    make ${MAKEOPTS} -C ports/esp32 submodules
    make ${MAKEOPTS} -C ports/esp32 \
        USER_C_MODULES=../../../examples/usercmodule/micropython.cmake \
        FROZEN_MANIFEST=$(pwd)/ports/esp32/boards/manifest_test.py
    make ${MAKEOPTS} -C ports/esp32 BOARD=GENERIC_C3
    make ${MAKEOPTS} -C ports/esp32 BOARD=GENERIC_S2
    make ${MAKEOPTS} -C ports/esp32 BOARD=GENERIC_S3

    # Test building native .mpy with xtensawin architecture.
    ci_native_mpy_modules_build xtensawin
}

