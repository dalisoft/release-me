#!/usr/bin/env bash
set -eu

REPO_FOLDER=$(mktemp -d)

setup_suite() {
  cd "$REPO_FOLDER"
  git init --initial-branch=master

  echo '{
  "name": "fake-me",
  "version": "1.0.0",
  "description": "> Except bugs, errors and/or strange behavior",
  "main": "index.js",
  "directories": {
    "doc": "docs",
    "test": "tests"
  },
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "",
  "license": "ISC"
}
' >>"$REPO_FOLDER/package.json"

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

  _npm() {
    # shellcheck disable=SC2317
    if [[ "${FAKE_PARAMS[0]}" == "publish" ]]; then
      return 0
    else
      exit 1
    fi
  }
  export -f _npm

  fake npm _npm
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

test_plugin_npm_0_1_initial_message_dryrun() {
  git commit -m "fix: initial commit" --allow-empty --no-gpg-sign

  NPM_TOKEN="FAKE_TOKEN" bash "$ROOT_DIR/release.sh" --plugins=npm --quiet --dry-run
  assert_matches "1.0.0" "$(cat package.json)"
}
test_plugin_npm_0_2_initial_message() {
  assert_matches "v0.0.1" "$(NPM_TOKEN="FAKE_TOKEN" bash "$ROOT_DIR/release.sh" --plugins=npm --quiet)"
  assert_matches "0.0.1" "$(cat package.json)"
}
test_plugin_npm_no_token_fail_message() {
  assert_status_code 1 "$(bash "$ROOT_DIR/release.sh" --plugins=npm --quiet)"
}
