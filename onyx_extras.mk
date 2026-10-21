#
# SPDX-FileCopyrightText: 2026 alexssandro56
# SPDX-License-Identifier: Apache-2.0
#
# Inherit from device/xiaomi/onyx/device.mk:
#   $(call inherit-product-if-exists, vendor/onyx-extras/onyx_extras.mk)
#

# GameSpace
PRODUCT_PACKAGES += \
    GameSpace

PRODUCT_COPY_FILES += \
    vendor/onyx-extras/gamespace/init/onyx_extras.rc:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/init/onyx_extras.rc

# Shows GameSpace's bypass charging switch, see gamespace/init/onyx_extras.rc
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    persist.sys.battery_bypass_supported=true

# AFME frame generation layers, loaded into the game GameSpace arms
PRODUCT_PACKAGES += \
    libAFME_layer \
    libVkLayer_AFME

# mithermald (replaces the stock mi_thermald)
PRODUCT_PACKAGES += \
    mi_thermal_engine
