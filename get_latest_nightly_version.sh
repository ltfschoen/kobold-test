#!/bin/bash

# Latest Rust Toolchain Nightly Version Scraper, Version 1.0.0
# Copyright (c) 2023 Luke Schoen <ltfschoen@gmail.com>
#
# Usage Instructions:
#
# * Set execute permissions `chmod 755 get_latest_nightly_version.sh`
# * Run `. ./get_latest_nightly_version.sh` or `source ./get_latest_nightly_version.sh`
#   in a folder where rust-toolchain.toml has been generated with a `[toolchain]` section and `channel` property.
#   This script will output the nightly version `x.x.x` value of the `channel`
#   and set it as the value of an environment variable LATEST_NIGHTLY_VERSION of the calling
#   shell. In the calling shell it may be accessed (i.e. `echo $LATEST_NIGHTLY_VERSION`)

LINE_START=$(grep -n -m 1 "\[toolchain\]" rust-toolchain.toml | cut -f1 -d:)
echo "Found [toolchain] on line: $LINE_START"
LINE_CHANNEL=$(awk "NR >= $LINE_START && /channel/{print NR}" rust-toolchain.toml | head -1)
echo "Found [toolchain] channel on line: $LINE_CHANNEL"
LINE_CHANNEL_CONTENTS=$(awk "NR==$LINE_CHANNEL{ print; exit }" rust-toolchain.toml)
echo "Contents of [toolchain] channel line number: $LINE_CHANNEL_CONTENTS"
LATEST_NIGHTLY_VERSION=$(echo "$LINE_CHANNEL_CONTENTS" | sed 's/channel//;s/=//;s/nightly//;s/\-//;s/\"//g' | xargs)
echo "[toolchain] channel nightly version is: $LATEST_NIGHTLY_VERSION"
echo $LATEST_NIGHTLY_VERSION
export LATEST_NIGHTLY_VERSION=$LATEST_NIGHTLY_VERSION
