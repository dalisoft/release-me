#!/bin/sh
set -eu

REPO_FOLDER=$(mktemp -d)

setup_suite() {
  ROOT_DIR="$(realpath ../../)"
  sh "$ROOT_DIR/install.sh" --outdir="$REPO_FOLDER" --preset=conventional-commits --plugins=git

  cd "$REPO_FOLDER"
}

teardown_suite() {
  rm -rf "$REPO_FOLDER"
}

#####################################
## This tests of specification at  ##
## https://conventionalcommits.org ##
#####################################

test_nogit_1() {
  assert_matches "Current directory is not a Git repository!" "$(bash "release.sh" --plugin=PLUGIN_TEMPLATE)"
}
