#!/bin/bash

## Getting the Distro info
DISTRO=$(cat /etc/*-release | grep -w NAME | cut -d "=" -f2 | sed 's/\"//g')

switch_distro() {
    case $DISTRO in
        "Arch Linux")
            echo "Arch Linux"
            ;;
        "Ubuntu")
            echo "Ubuntu"
            ;;
        "Fedora")
            echo "Fedora"
            ;;
        "Debian GNU/Linux")
            echo "Debian"
            ;;
        *)
            echo "Unknown Distro"
            ;;
    esac
}

ubuntu() {
    echo "Ubuntu"
}

