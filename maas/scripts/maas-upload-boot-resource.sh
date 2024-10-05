#!/usr/bin/env bash

set -eo pipefail

export ARCH=
export FILETYPE=
export SOURCE_FILE=
export TITLE=
export NAME=
export OPTARG=
export MAAS_API_BASE=${MAAS_API_BASE}
export MAAS_API_KEY=${MAAS_API_KEY}

while getopts "a:b:f:i:k:n:t:?" opt; do
    case $opt in
        a) export ARCH=$OPTARG;;
        b) export MAAS_API_BASE=$OPTARG;;
        f) export FILETYPE=$OPTARG;;
        i)
            export SOURCE_FILE=$OPTARG
            if test ! -f "${SOURCE_FILE}" ; then
                echo "File not found: ${SOURCE_FILE}" >&2
                exit 1
            fi
            ;;
        k) export MAAS_API_KEY=$OPTARG;;
        n) export NAME=$OPTARG;;
        t) export TITLE=$OPTARG;;
        \?)
            echo "usage: $0 <-i SOURCE_FILE> <-n NAME> <-f FILETYPE> <-a ARCH> [-t TITLE]"
            exit 1
            ;;
    esac
done

declare -a required=(
    "MAAS_API_BASE"
    "MAAS_API_KEY"
    "ARCH"
    "NAME"
    "SOURCE_FILE"
)
for var_name in "${required}"
do
    var_value="${!var_name}"
    if test -z "${var_value}" ; then
        echo "${var_name} is not set, exiting"
        exit 1
    fi
done

set -u

maas login default "${MAAS_API_BASE}" "${MAAS_API_KEY}"

size_bytes=$(ls -1l "${SOURCE_FILE}" | awk '{print $5}')
checksum=$(sha256sum -b "${SOURCE_FILE}" | awk '{print $1}')

maas default boot-resources create \
    "name=${NAME}" \
    "architecture=${ARCH}" \
    "sha256=${checksum}" \
    "size=${size_bytes}" \
    "title=${TITLE:-}" \
    "filetype=${FILETYPE}" \
    "content@=${SOURCE_FILE}"