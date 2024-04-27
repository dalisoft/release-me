#!/usr/bin/env bash
set -eu

ROOT_DIR="$(realpath ../../)"
REPO_FOLDER=$(mktemp -d)

setup_suite() {
  cd "$REPO_FOLDER"
  git init --quiet --initial-branch=master

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
  git add package.json
  git commit -m "initial commit" --no-gpg-sign

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
    if [[ "${FAKE_PARAMS[0]}" == "publish" && "${NPM_TOKEN-}" == "FAKE_TOKEN" ]]; then
      return 0
    else
      exit 1
    fi
  }
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

  export -f _npm
  export -f git

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

test_plugin_npm_post_0_1_initial_message_dryrun() {
  git commit --quiet -m "fix: bump version?" --allow-empty --no-gpg-sign

  NPM_TOKEN="FAKE_TOKEN" bash "$ROOT_DIR/release.sh" --plugins=npm,npm-post,git --dry-run
  assert_matches "1.0.0" "$(cat package.json)"
}
test_plugin_npm_post_0_2_initial_message() {
  assert_matches "npm tag: v0.0.1 and version: v0.0.1" "$(NPM_TOKEN="FAKE_TOKEN" bash "$ROOT_DIR/release.sh" --plugins=npm,npm-post,git --verbose)"
  assert_matches "0.0.1" "$(cat package.json)"
}
test_plugin_npm_post_0_3_no_gpg_message() {
  git commit --quiet -m "fix: no gpg bump" --allow-empty --no-gpg-sign

  assert_matches "npm tag: v0.0.2 and version: v0.0.2" "$(NPM_TOKEN="FAKE_TOKEN" bash "$ROOT_DIR/release.sh" --plugins=npm,npm-post,git --verbose)"
  assert_matches "0.0.2" "$(cat package.json)"
}
test_plugin_npm_post_0_4_no_gpg_sign_message() {
  git commit --quiet -m "fix: no gpg sign bump" --allow-empty --no-gpg-sign

  assert_matches "npm tag: v0.0.3 and version: v0.0.3" "$(NPM_TOKEN="FAKE_TOKEN" GPG_NO_SIGN=1 bash "$ROOT_DIR/release.sh" --plugins=npm,npm-post,git --verbose)"
  assert_matches "0.0.3" "$(cat package.json)"
}
test_plugin_npm_post_0_5_custom_gpg_npm_message_preinstalled() {
  echo "$GPG_KEY" | base64 --decode | gpg --quiet --batch --import
  echo "$GPG_PASSPHRASE" | gpg --quiet --batch --yes --pinentry-mode loopback --sign --local-user "${GPG_KEY_ID}" --passphrase-fd 0 >/dev/null
  echo "" | gpg --quiet --local-user "${GPG_KEY_ID}" --clearsign >/dev/null

  git commit --quiet -m "fix: gpg bump npm pre-installed" --allow-empty --no-gpg-sign

  assert_matches "npm tag: v0.0.4 and version: v0.0.4" "$(NPM_TOKEN="FAKE_TOKEN" bash "$ROOT_DIR/release.sh" --plugins=npm,npm-post,git --verbose)"
  assert_matches "0.0.4" "$(cat package.json)"
}
test_plugin_npm_post_0_6_custom_gpg_npm_message() {
  unset GPG_KEY_ID
  unset GPG_PASSPHRASE
  unset GPG_KEY

  export GPG_KEY_ID="${GPG_KEY_ID_UNSAFE-}"
  export GPG_KEY="${GPG_KEY_UNSAFE-}"
  export GPG_PASSPHRASE=

  git commit --quiet -m "fix: gpg bump npm" --allow-empty --no-gpg-sign

  assert_matches "npm tag: v0.0.5 and version: v0.0.5" "$(NPM_TOKEN="FAKE_TOKEN" bash "$ROOT_DIR/release.sh" --plugins=npm,npm-post,git --verbose)"
  assert_matches "0.0.5" "$(cat package.json)"
}
test_plugin_npm_post_0_7_custom_gpg_npm_message_preinstalled() {
  unset GPG_KEY_ID
  unset GPG_PASSPHRASE
  unset GPG_KEY

  export GPG_KEY_ID="${GPG_KEY_ID_UNSAFE-}"
  export GPG_KEY="${GPG_KEY_UNSAFE-}"
  export GPG_PASSPHRASE=

  echo "$GPG_KEY" | base64 --decode | gpg --quiet --batch --import

  git commit --quiet -m "fix: gpg bump npm" --allow-empty --no-gpg-sign

  assert_matches "npm tag: v0.0.6 and version: v0.0.6" "$(NPM_TOKEN="FAKE_TOKEN" bash "$ROOT_DIR/release.sh" --plugins=npm,npm-post,git --verbose)"
  assert_matches "0.0.6" "$(cat package.json)"
}
test_plugin_npm_post_no_pkg_fail_message() {
  git commit --quiet -m "fix: update commit" --allow-empty --no-gpg-sign

  rm -rf package.json
  assert_matches "Project does not have package.json" "$(NPM_TOKEN="FAKE_TOKEN" bash "$ROOT_DIR/release.sh" --plugins=npm-post,git --verbose)"
  assert_status_code 1 "$ROOT_DIR/release.sh --plugins=npm-post,git --quiet"
}
test_plugin_npm_post_no_token_fail_message() {
  git commit --quiet -m "fix: update commit" --allow-empty --no-gpg-sign

  assert_status_code 1 "$ROOT_DIR/release.sh --plugins=npm-post,git --quiet"
}
