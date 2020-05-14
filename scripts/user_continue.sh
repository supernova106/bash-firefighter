#!/bin/bash

function user_continue() {
    while true; do
      read -r -p "Continue? [Y/N]" yn
      case $yn in
          [Yy]* ) break;;
          [Nn]* ) echo "aborting";exit;;
          * ) echo "Please answer y for yes or n for no.";;
      esac
    done
}

user_continue