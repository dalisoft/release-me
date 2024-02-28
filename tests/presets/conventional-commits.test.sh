#!/usr/bin/env bash
set -e

PROJECT_DIR=$(pwd)
REPO_FOLDER=$(mktemp -d)

setup_suite() {
  cd "$REPO_FOLDER"
  git init

  export GIT_DIR="$REPO_FOLDER/.git"
  export GIT_WORK_TREE="$REPO_FOLDER"
}

teardown_suite() {
  rm -rf "$REPO_FOLDER"
  unset REPO_FOLDER
  cd "$PROJECT_DIR"

  unset GIT_DIR
  unset GIT_WORK_TREE
}

test_commit_fix_message() {
  git commit -m "fix: initial commit" --allow-empty --no-gpg-sign
  bash "$PROJECT_DIR/../../release.sh" --plugins=git --quiet

  assert_equals "v0.0.1" "$(git tag -l | tail -1)"
}
test_commit_feat_message() {
  git commit -m "feat: update commit" --allow-empty --no-gpg-sign
  bash "$PROJECT_DIR/../../release.sh" --plugins=git --quiet

  assert_equals "v0.1.0" "$(git tag -l | tail -1)"
}
test_commit_feat_major_message() {
  git commit -m "feat!: breaking change commit" --allow-empty --no-gpg-sign
  bash "$PROJECT_DIR/../../release.sh" --plugins=git --quiet

  assert_equals "v0.2.0" "$(git tag -l | tail -1)"
}
