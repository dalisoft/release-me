#!/bin/sh
set -eu

REPO_FOLDER=$(mktemp -d)

setup_suite() {
  ROOT_DIR="$(realpath ../../)"
  sh "$ROOT_DIR/install.sh" --outdir="$REPO_FOLDER" --preset=conventional-commits --plugins=git

  cd "$REPO_FOLDER"
  git init --initial-branch=master

  export GIT_DIR="$REPO_FOLDER/.git"
  export GIT_CONFIG="$REPO_FOLDER/.gitconfig"
  export GIT_WORK_TREE="$REPO_FOLDER"

  if [ -n "${GIT_USERNAME-}" ] && [ -n "${GIT_EMAIL-}" ]; then
    export GIT_COMMITTER_NAME="$GIT_USERNAME"
    export GIT_COMMITTER_EMAIL="$GIT_EMAIL"
    export GIT_AUTHOR_NAME="$GIT_USERNAME"
    export GIT_AUTHOR_EMAIL="$GIT_EMAIL"

    git config user.email "$GIT_EMAIL"
    git config user.name "$GIT_USERNAME"
  fi

  export GPG_NO_SIGN=1
}

teardown_suite() {
  rm -rf "$GIT_WORK_TREE"
  unset REPO_FOLDER
  unset GIT_DIR
  unset GIT_CONFIG
  unset GIT_WORK_TREE

  unset GIT_COMMITTER_NAME
  unset GIT_COMMITTER_EMAIL
  unset GIT_AUTHOR_NAME
  unset GIT_AUTHOR_EMAIL
}

#####################################
## This tests of specification at  ##
## https://conventionalcommits.org ##
#####################################

test_core_cli_help() {
  assert_matches "release-me" "$(bash "release.sh" --help)"
}
test_core_cli_version() {
  assert_matches "last version available at GitHub" "$(bash "release.sh" --version)"
}
test_core_cli_invalid_option() {
  assert_matches "Unknown option: --invalid" "$(bash "release.sh" --invalid)"
  assert_status_code 1 "./release.sh --invalid"
}
test_core_cli_invalid_arg() {
  assert_matches "Unknown argument: invalid" "$(bash "release.sh" invalid)"
  assert_status_code 1 "./release.sh invalid"
}
