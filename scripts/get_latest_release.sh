#!/bin/bash

get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

REPO_NAME=$1

if [ -z "${REPO_NAME}" ]; then
  echo "REPO_NAME is required"
  exit 1
fi

get_latest_release ${REPO_NAME}
