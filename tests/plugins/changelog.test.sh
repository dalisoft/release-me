#!/usr/bin/env bash
set -eu

ROOT_DIR="$(realpath ../../)"
REPO_FOLDER=$(mktemp -d)

setup_suite() {
  cd "${REPO_FOLDER}"
  git init --quiet --initial-branch=master

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

  export GPG_NO_SIGN=1
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
}

#####################################
## This tests of specification at  ##
## https://conventionalcommits.org ##
#####################################

test_plugin_changelog_1() {
  git commit --quiet -m "fix: initial commit" --allow-empty --no-gpg-sign

  bash "${ROOT_DIR}/release.sh" --plugins=git,changelog --quiet

  assert_matches "v0.0.1" "$(cat CHANGELOG.md)"
  assert_matches "initial commit" "$(cat CHANGELOG.md)"
}

test_plugin_changelog_2_dryun() {
  git commit --quiet -m "fix: bump version" --allow-empty --no-gpg-sign

  bash "${ROOT_DIR}/release.sh" --plugins=git,changelog --quiet --dry-run

  assert_not_matches "v0.0.2" "$(cat CHANGELOG.md)"
  assert_not_matches "bump version" "$(cat CHANGELOG.md)"
}

test_plugin_changelog_3_update() {
  git commit --quiet -m "feat: feat version" --allow-empty --no-gpg-sign

  bash "${ROOT_DIR}/release.sh" --plugins=git,changelog --quiet

  assert_matches "v0.1.0" "$(cat CHANGELOG.md)"
  assert_matches "feat version" "$(cat CHANGELOG.md)"
}
