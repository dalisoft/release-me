#!/usr/bin/env bash
set -eu

ROOT_DIR="$(realpath ../../)"
REPO_FOLDER=$(mktemp -d)

setup_suite() {
  ROOT_DIR="$(realpath ../../)"
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
  assert_matches "Current directory is not a Git repository!" "$(bash "$ROOT_DIR/release.sh" --plugin=PLUGIN_TEMPLATE)"
}
