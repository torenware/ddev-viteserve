#! /usr/bin/env bash
#ddev-generated

BASE_DIR=$(dirname $0)
echo "BASEDIR $BASE_DIR"
$BASE_DIR/build-dotenv1.sh "$@"
$BASE_DIR/build-dotenv2.sh
$BASE_DIR/build-dotenv3.sh
