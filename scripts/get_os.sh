#!/bin/bash

get_os() {
    unameOut="$(uname -s)"
    local machine=""
    case "${unameOut}" in
        Linux*)     machine=Linux;;
        Darwin*)    machine=Mac;;
        CYGWIN*)    machine=Cygwin;;
        MINGW*)     machine=MinGw;;
        *)          machine="UNKNOWN:${unameOut}"
    esac

    echo "$machine"
}

get_os