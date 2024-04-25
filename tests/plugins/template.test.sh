#!/usr/bin/env bash
set -eu

ROOT_DIR="$(realpath ../../)"
REPO_FOLDER=$(mktemp -d)

setup_suite() {
  cd "$REPO_FOLDER"
  git init --quiet --initial-branch=master

  export GIT_DIR="$REPO_FOLDER/.git"
  export GIT_CONFIG="$GIT_DIR/.gitconfig"
  export GIT_WORK_TREE="$REPO_FOLDER"
}

teardown_suite() {
  rm -rf "$GIT_WORK_TREE"
  unset REPO_FOLDER
  unset GIT_DIR
  unset GIT_CONFIG
  unset GIT_WORK_TREE
}

#####################################
## This tests of specification at  ##
## https://conventionalcommits.org ##
#####################################

test_plugin_template() {
  git commit --quiet -m "fix: initial commit" --allow-empty

  bash "$ROOT_DIR/release.sh" --plugins=git,PLUGIN_TEMPLATE --quiet
}
