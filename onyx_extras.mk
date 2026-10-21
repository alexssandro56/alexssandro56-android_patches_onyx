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

# mithermald (replaces the stock mi_thermald)
PRODUCT_PACKAGES += \
    mi_thermal_engine
