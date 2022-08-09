#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
# Copyright (C) 2020 Raphielscape LLC. and Haruka LLC.
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=surya
VENDOR=xiaomi

PROPRIETARY_FILES=proprietary-files.txt
PROPRIETARY_FILES_OTHER=proprietary-files-flame.txt

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

HENTAI_ROOT="${MY_DIR}/../../.."

HELPER="${HENTAI_ROOT}/vendor/hentai/build/tools/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Path to dumps
FIRST_LINE=$(sed -n '1p' ${PROPRIETARY_FILES}) && PACKAGE_NAME=${FIRST_LINE//# Blobs extracted from }
FIRST_LINE_OTHER=$(sed -n '1p' ${PROPRIETARY_FILES_OTHER}) && PACKAGE_NAME_OTHER=${FIRST_LINE_OTHER//# Blobs extracted from }
UNIFIED_PATH="${HENTAI_ROOT}/../dumpyara/working"
SRC1="${UNIFIED_PATH}/${PACKAGE_NAME}"
SRC2="${UNIFIED_PATH}/${PACKAGE_NAME_OTHER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in
        system_ext/lib64/lib-imsvideocodec.so)
            "${PATCHELF}" --add-needed "libgui-shim.so" "${2}"
            ;;
    esac
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${HENTAI_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/${PROPRIETARY_FILES}" "${SRC1}" "${KANG}" --section "${SECTION}"
extract "${MY_DIR}/${PROPRIETARY_FILES_OTHER}" "${SRC2}" "${KANG}" --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"
