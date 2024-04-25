#!/usr/bin/env bash
set -eu

ROOT_DIR="$(realpath ../../)"
REPO_FOLDER=$(mktemp -d)
ORIGINAL_GH_TOKEN="${GITHUB_TOKEN-}"

setup_suite() {
  cd "$REPO_FOLDER"
  git init --quiet --initial-branch=master

  # unset it to make this test work
  unset GITHUB_TOKEN

  export GIT_DIR="$REPO_FOLDER/.git"
  export GIT_CONFIG="$GIT_DIR/.gitconfig"
  export GIT_WORK_TREE="$REPO_FOLDER"

  fake_curl() {
    # shellcheck disable=SC2317
    echo "${GITHUB_TOKEN-}"
    # shellcheck disable=SC2317
    echo "${FAKE_PARAMS[@]}"
  }
  export -f fake_curl

  fake curl fake_curl
}

teardown_suite() {
  export GITHUB_TOKEN="$ORIGINAL_GH_TOKEN"

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

test_plugin_gh_0_1_initial_message_dryrun() {
  git commit --quiet -m "fix: initial commit" --allow-empty

  GITHUB_TOKEN="FAKE_TOKEN" bash "$ROOT_DIR/release.sh" --plugins=git,github-release --quiet --dry-run --pre-release
  assert_not_matches "v0.0.1" "$(git tag -l)"
}
test_plugin_gh_0_2_initial_message() {
  assert_matches "v0.0.1" "$(GITHUB_TOKEN="FAKE_TOKEN" bash "$ROOT_DIR/release.sh" --plugins=git,github-release --quiet)"
  assert_matches "v0.0.1" "$(git tag -l)"
}
test_plugin_gh_no_token_fail_message() {
  git commit --quiet -m "fix: initial commit" --allow-empty

  assert_matches "v0.0.1" "$(git tag -l)"
  assert_not_matches "v0.0.2" "$(git tag -l)"
  assert_status_code 1 "$ROOT_DIR/release.sh --plugins=github-release --quiet"
}
