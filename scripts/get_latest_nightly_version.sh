#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# Latest Rust Toolchain Nightly Version Scraper, Version 1.0.0
# Copyright (c) 2023 Luke Schoen <ltfschoen@gmail.com>
#
# Usage Instructions:
#
# * Set execute permissions `chmod 755 ./scripts/get_latest_nightly_version.sh`
# * Run `. ./scripts/get_latest_nightly_version.sh` or `source ./scripts/get_latest_nightly_version.sh`.
#   Change PATH_TO_RUSTTOOLCHAIN_TOML to the path to the rust-toolchain.toml file
#   with a `[toolchain]` section and `channel` property.
#   This script will output the nightly version `x.x.x` value of the `channel`
#   and set it as the value of an environment variable LATEST_NIGHTLY_VERSION of the calling
#   shell. In the calling shell it may be accessed (i.e. `echo $LATEST_NIGHTLY_VERSION`)

PATH_TO_RUSTTOOLCHAIN_TOML=$(dirname "$(dirname "$(realpath "${BASH_SOURCE[0]}")")")
LINE_START=$(grep -n -m 1 "\[toolchain\]" $PATH_TO_RUSTTOOLCHAIN_TOML/rust-toolchain.toml | cut -f1 -d:)
echo "Found [toolchain] on line: $LINE_START"
LINE_CHANNEL=$(awk "NR >= $LINE_START && /channel/{print NR}" $PATH_TO_RUSTTOOLCHAIN_TOML/rust-toolchain.toml | head -1)
echo "Found [toolchain] channel on line: $LINE_CHANNEL"
LINE_CHANNEL_CONTENTS=$(awk "NR==$LINE_CHANNEL{ print; exit }" $PATH_TO_RUSTTOOLCHAIN_TOML/rust-toolchain.toml)
echo "Contents of [toolchain] channel line number: $LINE_CHANNEL_CONTENTS"
LATEST_NIGHTLY_VERSION=$(echo "$LINE_CHANNEL_CONTENTS" | sed 's/channel//;s/=//;s/nightly//;s/\-//;s/\"//g' | xargs)
echo "[toolchain] channel nightly version is: $LATEST_NIGHTLY_VERSION"
echo $LATEST_NIGHTLY_VERSION
export LATEST_NIGHTLY_VERSION=$LATEST_NIGHTLY_VERSION
