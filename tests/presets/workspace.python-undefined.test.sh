#!/usr/bin/env bash
set -eu

ROOT_DIR="$(realpath ../../)"
REPO_FOLDER=$(mktemp -d)

setup_suite() {
  cd "$REPO_FOLDER"
  git init --quiet --initial-branch=master

  echo 'from setuptools import setup, find_packages


setup(
    name="",
    version="0.0.0",
    packages=find_packages(),
)
' >>"$REPO_FOLDER/setup.py"

  export GIT_DIR="$REPO_FOLDER/.git"
  export GIT_CONFIG="$REPO_FOLDER/.gitconfig"
  export GIT_WORK_TREE="$REPO_FOLDER"

  if [[ -n "${GIT_USERNAME-}" && -n "${GIT_EMAIL-}" ]]; then
    export GIT_COMMITTER_NAME="$GIT_USERNAME"
    export GIT_COMMITTER_EMAIL="$GIT_EMAIL"
    export GIT_AUTHOR_NAME="$GIT_USERNAME"
    export GIT_AUTHOR_EMAIL="$GIT_EMAIL"

    git config user.email "$GIT_EMAIL"
    git config user.name "$GIT_USERNAME"
  fi
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

test_commit_initial_message() {
  git commit -m "fix(workspace1): initial commit" --allow-empty

  assert_status_code 1 "GPG_NO_SIGN=1 $ROOT_DIR/release.sh --plugins=git --preset=workspace --workspace"
  assert_not_equals "workspace1-v0.0.1" "$(git tag -l | tail -1)"
}
test_commit_0_2_invalid_workspace() {
  git commit -m "fix(workspace3): initial commit" --allow-empty

  assert_matches "This release aims to being workspace release" "$(bash "$ROOT_DIR/release.sh" --plugins=git --preset=workspace --workspace --dry-run)"
}
test_commit_initial_message_2_no_change() {
  assert_status_code 1 "GPG_NO_SIGN=1 $ROOT_DIR/release.sh --plugins=git --preset=workspace --workspace"
}
