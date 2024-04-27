#!/usr/bin/env bash
set -eu

ROOT_DIR="$(realpath ../../)"
REPO_FOLDER=$(mktemp -d)

setup_suite() {
  cd "$REPO_FOLDER"
  git init --quiet --initial-branch=master

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

  unset GPG_KEY_ID
  unset GPG_PASSPHRASE
  unset GPG_KEY
}

test_gpg_sign_1_1_password() {
  git commit --quiet -m "fix: initial commit" --allow-empty --no-gpg-sign
  assert_matches "v0.0.1" "$(bash "$ROOT_DIR/release.sh" --plugins=git --verbose)"
}
test_gpg_sign_1_2_pre_installed() {
  echo "$GPG_KEY" | base64 --decode | gpg --quiet --batch --import
  echo "$GPG_PASSPHRASE" | gpg --quiet --batch --yes --pinentry-mode loopback --sign --local-user "${GPG_KEY_ID}" --passphrase-fd 0 >/dev/null

  git commit --quiet -m "fix: update commit" --allow-empty --no-gpg-sign
  assert_matches "v0.0.2" "$(bash "$ROOT_DIR/release.sh" --plugins=git --verbose)"
}

test_gpg_sign_2_1_passwordless() {
  unset GPG_KEY_ID
  unset GPG_PASSPHRASE
  unset GPG_KEY

  export GPG_KEY_ID="${GPG_KEY_ID_UNSAFE-}"
  export GPG_KEY="${GPG_KEY_UNSAFE-}"
  export GPG_PASSPHRASE=

  git commit --quiet -m "fix: update commit" --allow-empty --no-gpg-sign
  assert_matches "v0.0.3" "$(bash "$ROOT_DIR/release.sh" --plugins=git --verbose)"
}
test_gpg_sign_2_2_passwordless_pre_installed() {
  unset GPG_KEY_ID
  unset GPG_PASSPHRASE
  unset GPG_KEY

  export GPG_KEY_ID="${GPG_KEY_ID_UNSAFE-}"
  export GPG_KEY="${GPG_KEY_UNSAFE-}"
  export GPG_PASSPHRASE=

  echo "$GPG_KEY" | base64 --decode | gpg --quiet --batch --import

  git commit --quiet -m "fix: update commit" --allow-empty --no-gpg-sign
  assert_matches "v0.0.4" "$(bash "$ROOT_DIR/release.sh" --plugins=git --verbose)"
}
test_gpg_sign_2_3_passwordless_pre_removed() {
  unset GPG_KEY_ID
  unset GPG_PASSPHRASE
  unset GPG_KEY

  export GPG_KEY_ID="${GPG_KEY_ID_UNSAFE-}"
  export GPG_KEY=
  export GPG_PASSPHRASE=

  git commit --quiet -m "fix: update commit" --allow-empty --no-gpg-sign
  assert_matches "v0.0.5" "$(bash "$ROOT_DIR/release.sh" --plugins=git --verbose)"
}
