#!/bin/bash

# Latest Crate Version Scraper, Version 1.0.0
# Copyright (c) 2023 Luke Schoen <ltfschoen@gmail.com>
#
# Usage Instructions:
#
# * Set execute permissions `chmod 755 get_latest_crate_version.sh`
# * Run `. ./get_latest_crate_version.sh <CRATE_NAME>` or `source ./get_latest_crate_version.sh <CRATE_NAME>`
#   in a shell where `cargo` has been installed. This script will output that version `x.x.x` value
#   and set it as the value of an environment variable LATEST_CRATE_VERSION of the calling
#   shell. In the calling shell it may be accessed (i.e. `echo $LATEST_CRATE_VERSION`)

CRATE_NAME=$1
LATEST_CRATE_VERSION=$(echo $(cargo search $CRATE_NAME | head -1) | sed 's/\#[^*]*//' | sed "s/$CRATE_NAME//;s/=//;s/\"//g" | xargs)
echo "Latest version for crate $CRATE_NAME is: $LATEST_CRATE_VERSION"
echo $LATEST_CRATE_VERSION
export LATEST_CRATE_VERSION=$LATEST_CRATE_VERSION
