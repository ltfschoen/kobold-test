#!/bin/bash

# Cargo.toml Package Version Scraper, Version 1.0.0
# Copyright (c) 2023 Luke Schoen <ltfschoen@gmail.com>
#
# Usage Instructions:
#
# * Set execute permissions `chmod 755 ./scripts/set_cargo_package_version.sh`
# * Run `. ./scripts/set_cargo_package_version.sh` or `source ./scripts/set_cargo_package_version.sh`.
#   Change PATH_TO_CARGO_TOML to the path to the Cargo.toml file that contains a `[package]` section
#   that contains a `version = x.x.x`. This script will output that version `x.x.x` value
#   and set it as the value of an environment variable CARGO_PACKAGE_VERSION of the calling
#   shell. In the calling shell it may be accessed (i.e. `echo $CARGO_PACKAGE_VERSION`)
PATH_TO_CARGO_TOML=$(dirname "$(dirname "$(realpath "${BASH_SOURCE[0]}")")")
LINE_START=$(grep -n -m 1 "\[package\]" $PATH_TO_CARGO_TOML/Cargo.toml | cut -f1 -d:)
echo "Found [package] on line: $LINE_START"
LINE_VERSION=$(awk "NR >= $LINE_START && /version/{print NR}" $PATH_TO_CARGO_TOML/Cargo.toml | head -1)
echo "Found [package] version on line: $LINE_VERSION"
LINE_VERSION_CONTENTS=$(awk "NR==$LINE_VERSION{ print; exit }" $PATH_TO_CARGO_TOML/Cargo.toml)
echo "Contents of [package] version line number: $LINE_VERSION_CONTENTS"
CARGO_PACKAGE_VERSION=$(echo "$LINE_VERSION_CONTENTS" | sed 's/version//;s/=//;s/\"//g' | xargs)
echo "Package [package] version number is: $CARGO_PACKAGE_VERSION"
echo $CARGO_PACKAGE_VERSION
export CARGO_PACKAGE_VERSION=$CARGO_PACKAGE_VERSION
