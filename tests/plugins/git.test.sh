#!/usr/bin/env bash
set -eu

ROOT_DIR="$(realpath ../../)"
REPO_FOLDER=$(mktemp -d)

setup_suite() {
  cd "$REPO_FOLDER"
  git init --quiet --initial-branch=master

  # unset it to make this test work
  unset GITHUB_TOKEN

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

  git() {
    # shellcheck disable=SC2317
    if [ "$1" == "push" ]; then
      return 0
    elif [ "$1" == "remote" ]; then
      printf "%s" "https://github.com/dalisoft/release-me"
    else
      command git "$@"
    fi
  }
  export -f git
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

test_plugin_git_0_1_initial_message_dryrun() {
  git commit --quiet -m "fix: initial commit" --allow-empty --no-gpg-sign

  bash "$ROOT_DIR/release.sh" --plugins=git --dry-run --verbose --pre-release
  assert_not_matches "v0.0.1" "$(git tag -l)"
}
test_plugin_git_0_2_initial_message() {
  assert_matches "v0.0.1" "$(bash "$ROOT_DIR/release.sh" --plugins=git --verbose)"
  assert_matches "v0.0.1" "$(git tag -l)"
}
