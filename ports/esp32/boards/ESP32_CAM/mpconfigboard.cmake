set(IDF_TARGET esp32)
#set(CONFIG_ESP32_REV_MIN_3 "y")
#add_compile_options(-Os)

set(SDKCONFIG_DEFAULTS
    boards/sdkconfig.base
    boards/sdkconfig.ble
    boards/sdkconfig.spiram
    boards/ESP32_CAM/sdkconfig.esp32cam
)

if(NOT MICROPY_FROZEN_MANIFEST)
    set(MICROPY_FROZEN_MANIFEST ${MICROPY_BOARD_DIR}/manifest.py)
endif()

