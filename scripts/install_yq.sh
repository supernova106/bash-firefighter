#!/bin/bash

TMP_DIR="/tmp"
BIN_DIR="${HOME}/bin"
YQ_BIN="${BIN_DIR}"/yq
YQ_VERSION="3.2.1"

install_yq() {
    local yq_version="${1}"
    local current_yq_version=""

    mkdir -p "${BIN_DIR}"

    if [ -f "${BIN_DIR}"/yq ]; then
        current_yq_version=$($YQ_BIN --version | awk '{ print $3 }')
    fi

    if [[ -z "${yq_version}" ]]; then
        print_error "install_yq() failed. yq_version is required"
    fi

    if [ ! -f "${BIN_DIR}"/yq ] || [ "${current_yq_version}" != "${yq_version}" ]; then
        cd "${TMP_DIR}" && wget -q "https://github.com/mikefarah/yq/releases/download/${yq_version}/yq_linux_amd64" -O "${TMP_DIR}"/yq_linux_amd64 && \
            cp "${TMP_DIR}"/yq_linux_amd64 "${BIN_DIR}"/yq && \
            chmod +x "${BIN_DIR}"/yq && \
            rm "${TMP_DIR}"/yq_linux_amd64
    fi
}

install_yq "${YQ_VERSION}"
$YQ_BIN --version