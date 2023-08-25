MicroPython port to the ESP32-CAM
================================

This is a port of MicroPython to the Espressif ESP32 series of
microcontrollers.  It uses the ESP-IDF framework and MicroPython runs as
a task under FreeRTOS.

Supported features include:
- Using of PSRAM 
- Using configurable I2C hardware with I2C slave mode
- Using wrapper for ESP-logging
- REPL (Python prompt) over UART0.
- 16k stack for the MicroPython task and approximately 100k Python heap.
- Many of MicroPython's features are enabled: unicode, arbitrary-precision
  integers, single-precision floats, complex numbers, frozen bytecode, as
  well as many of the internal modules.
- Internal filesystem using the flash (currently 2M in size).
- The machine module with GPIO, UART, SPI, software I2C, ADC, DAC, PWM,
  TouchPad, WDT and Timer.
- The network module with WLAN (WiFi) support.
- Bluetooth low-energy (BLE) support via the bluetooth module.

Initial development of this ESP32 port was sponsored in part by Microbric Pty Ltd.
PSRAM, I2C driver and ESP-logging commonly used from 
[MicroPython_ESP32_psRAM_LoBo](https://github.com/loboris/MicroPython_ESP32_psRAM_LoBo).
rewritten to use ESP-IDF v5.0.2

Setting up ESP-IDF and the build environment
--------------------------------------------

MicroPython on ESP32 requires the Espressif IDF version 5 (IoT development
framework, aka SDK).  The ESP-IDF includes the libraries and RTOS needed to
manage the ESP32 microcontroller, as well as a way to manage the required
build environment and toolchains needed to build the firmware.

The ESP-IDF changes quickly and MicroPython only supports certain versions.
Currently MicroPython supports only v5.0.2.

To install the ESP-IDF the full instructions can be found at the
[Espressif Getting Started guide](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/index.html#installation-step-by-step).

If you are on a Windows machine then the [Windows Subsystem for
Linux](https://msdn.microsoft.com/en-au/commandline/wsl/install_guide) is the
most efficient way to install the ESP32 toolchain and build the project. If
you use WSL then follow the Linux instructions rather than the Windows
instructions.

The Espressif instructions will guide you through using the `install.sh`
(or `install.bat`) script to download the toolchain and set up your environment.
The steps to take are summarised below.

To check out a copy of the IDF use git clone:

```bash
$ git clone -b v5.0.2 --recursive https://github.com/espressif/esp-idf.git
```

You can replace `v5.0.2` with any other supported version.
(You don't need a full recursive clone; see the `ci_esp32_setup` function in
`tools/ci.sh` in this repository for more detailed set-up commands.)

If you already have a copy of the IDF then checkout a version compatible with
MicroPython and update the submodules using:

```bash
$ cd esp-idf
$ git checkout v5.0.2
$ git submodule update --init --recursive
```

After you've cloned and checked out the IDF to the correct version, run the
`install.sh` script:

```bash
$ cd esp-idf
$ ./install.sh       # (or install.bat on Windows)
$ source export.sh   # (or export.bat on Windows)
```

The `install.sh` step only needs to be done once. You will need to source
`export.sh` for every new session.

Building the firmware
---------------------

The MicroPython cross-compiler must be built to pre-compile some of the
built-in scripts to bytecode.  This can be done by (from the root of
this repository):

```bash
$ make -C mpy-cross
```

Then to build MicroPython for the ESP32 run:

```bash
$ cd ports/esp32
$ ./make.sh
```

This will produce a combined `firmware-camera.bin` image in the `build/`
subdirectory (this firmware image is made up of: bootloader.bin, partitions.bin
and micropython.bin).

To flash the firmware you must have your ESP32 module in the bootloader
mode and connected to a serial port on your PC.  Refer to the documentation
for your particular ESP32 module for how to do this.
You will also need to have user permissions to access the `/dev/ttyUSB0` device.
On Linux, you can enable this by adding your user to the `dialout` group, and
rebooting or logging out and in again. (Note: on some distributions this may
be the `uucp` group, run `ls -la /dev/ttyUSB0` to check.)

```bash
$ sudo adduser <username> dialout
```

If you are installing MicroPython to your module for the first time, or
after installing any other firmware, you should first erase the flash
completely:

```bash
$ ./mclean.sh
```

Note: the above "make.sh" commands are thin wrappers for the underlying `idf.py`
build tool that is part of the ESP-IDF.  You can instead use `idf.py` directly,
for example:

```bash
$ idf.py -D MICROPY_BOARD=ESP32_CAM build
$ idf.py flash
```

Getting a Python prompt on the device
-------------------------------------

You can get a prompt via the serial port, via UART0, which is the same UART
that is used for programming the firmware.  The baudrate for the REPL is
115200 and you can use a command such as:

```bash
$ picocom -b 115200 /dev/ttyUSB0
```

or

```bash
$ miniterm.py /dev/ttyUSB0 115200
```

You can also use `idf.py monitor`.


Configuring camera with ESP32-CAM board
---------------------------------------

```python
import camera

camera.init(0, format = camera.JPEG)
flash = Pin(4, Pin.OUT, 0)
buf = camera.capture()
print(len(buf)
```

Configuring the I2C Slave mode with ESP32-CAM board
---------------------------------------------------

The callback version is:

```python
from machine import I2C

uplink=I2C(scl=12, sda=13, mode=I2C.SLAVE)
uplink.callback(lambda res:print(res.getcbdata())) #read all bytes from I2C master node
```

or use getdata function

```python
from machine import I2C

uplink=I2C(scl=12, sda=13, mode=I2C.SLAVE)
uplink.getdata(0, 10) # read 10 bytes from I2C master node
```

Configuring the ESP-logging
---------------------------

```python
import machine
machine.loglevel("*",5)
machine.redirectlog()
...
machine.restorelog()
```

Getting heap info
-----------------

```python
import machine
machine.heap_info()
```
