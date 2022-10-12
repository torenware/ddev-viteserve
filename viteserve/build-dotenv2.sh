#! /usr/bin/env bash
#ddev-generated
cd .ddev
if [ -f .allow-upgrade ]; then
    if grep ask .allow-upgrade >/dev/null; then
        read replace
        if [ "$replace" = "y" ]; then
            echo "true" >.allow-upgrade
        else
            echo "false" >.allow-upgrade
        fi
    fi
fi
