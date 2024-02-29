#!/usr/bin/env bash
set -e

PROJECT_DIR=$(pwd)
REPO_FOLDER=$(mktemp -d)

setup_suite() {
  cd "$REPO_FOLDER"
  git init --initial-branch=master

  export GIT_DIR="$REPO_FOLDER/.git"
  export GIT_WORK_TREE="$REPO_FOLDER"

  if [[ -n "$GIT_USERNAME" && -n "$GIT_EMAIL" ]]; then
    export GIT_COMMITTER_NAME="$GIT_USERNAME"
    export GIT_COMMITTER_EMAIL="$GIT_EMAIL"
    export GIT_AUTHOR_NAME="$GIT_USERNAME"
    export GIT_AUTHOR_EMAIL="$GIT_EMAIL"

    git config --local user.email "$GIT_EMAIL"
    git config --local user.name "$GIT_USERNAME"
  fi
}

teardown_suite() {
  cd "$PROJECT_DIR"

  rm -rf "$GIT_WORK_TREE"
  unset REPO_FOLDER
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
