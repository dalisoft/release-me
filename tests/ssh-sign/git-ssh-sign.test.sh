#!/usr/bin/env bash
set -eu

CURRENT_DIR=$(pwd)
ROOT_DIR="$(realpath ../../)"
REPO_FOLDER=$(mktemp -d)

setup_suite() {
  cd "${REPO_FOLDER}"
  git init --quiet --initial-branch=master

  export GPG_NO_SIGN=1
  export GIT_DIR="${REPO_FOLDER}/.git"
  export GIT_CONFIG="${REPO_FOLDER}/.gitconfig"
  export GIT_WORK_TREE="${REPO_FOLDER}"

  if [[ -n "${GIT_USERNAME-}" && -n "${GIT_EMAIL-}" ]]; then
    export GIT_COMMITTER_NAME="${GIT_USERNAME}"
    export GIT_COMMITTER_EMAIL="${GIT_EMAIL}"
    export GIT_AUTHOR_NAME="${GIT_USERNAME}"
    export GIT_AUTHOR_EMAIL="${GIT_EMAIL}"

    git config user.email "${GIT_EMAIL}"
    git config user.name "${GIT_USERNAME}"
  fi
}

teardown_suite() {
  rm -rf "${GIT_WORK_TREE}"
  unset REPO_FOLDER
  unset GIT_DIR
  unset GIT_CONFIG
  unset GIT_WORK_TREE

  unset GIT_COMMITTER_NAME
  unset GIT_COMMITTER_EMAIL
  unset GIT_AUTHOR_NAME
  unset GIT_AUTHOR_EMAIL

  unset GPG_NO_SIGN
  unset SSH_PRIVATE_KEY
  unset SSH_PUBLIC_KEY
}

test_ssh_sign_2_1_passwordless() {
  unset SSH_PRIVATE_KEY
  unset SSH_PUBLIC_KEY

  # Fix permissions
  chmod 600 "${CURRENT_DIR}/sign"
  chmod 600 "${CURRENT_DIR}/sign.pub"

  SSH_PRIVATE_KEY=$(cat "${CURRENT_DIR}/sign" | base64)
  SSH_PUBLIC_KEY=$(cat "${CURRENT_DIR}/sign.pub")

  export SSH_PRIVATE_KEY
  export SSH_PUBLIC_KEY

  git commit --quiet -m "fix: update commit" --allow-empty --no-gpg-sign
  assert_matches "v0.0.1" "$(bash "${ROOT_DIR}/release.sh" --plugins=git --verbose)"
}
