TMP_DIR="/tmp"
BIN_DIR="${HOME}/bin"
JQ_BIN="${BIN_DIR}"/jq
JQ_VERSION="1.6"

install_jq() {
    local jq_version="${1}"
    local current_jq_version=""

    mkdir -p "${BIN_DIR}"

    if [ -f "${BIN_DIR}"/jq ]; then
        current_jq_version=$($JQ_BIN --version | awk '{ print $2 }')
    fi 

    if [[ -z "${jq_version}" ]]; then
        print_error "install_jq() failed. jq_version is required"
    fi

    if [ ! -f "${BIN_DIR}"/jq ] || [ "${current_jq_version}" != "${jq_version}" ]; then
        cd "${TMP_DIR}" && wget -q "https://github.com/stedolan/jq/releases/download/jq-${jq_version}/jq-linux64" -O "${TMP_DIR}"/jq-linux64 && \
            cp "${TMP_DIR}"/jq-linux64 "${BIN_DIR}"/jq && \
            chmod +x "${BIN_DIR}"/jq && \
            rm "${TMP_DIR}"/jq-linux64
    fi
}


install_jq "${JQ_VERSION}"
$JQ_BIN --version