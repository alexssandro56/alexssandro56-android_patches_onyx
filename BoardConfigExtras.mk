#
# SPDX-FileCopyrightText: 2026 alexssandro56
# SPDX-License-Identifier: Apache-2.0
#
# Include from device/xiaomi/onyx/BoardConfig.mk:
#   -include vendor/onyx-extras/BoardConfigExtras.mk
#

BOARD_VENDOR_SEPOLICY_DIRS += \
    vendor/onyx-extras/gamespace/sepolicy/vendor \
    vendor/onyx-extras/mithermald/sepolicy/vendor
SYSTEM_EXT_PUBLIC_SEPOLICY_DIRS += vendor/onyx-extras/gamespace/sepolicy/public
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += vendor/onyx-extras/gamespace/sepolicy/private
