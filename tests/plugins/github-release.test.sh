#!/usr/bin/env bash
set -eu

ROOT_DIR="$(realpath ../../)"
REPO_FOLDER=$(mktemp -d)
ORIGINAL_TOKEN="${GITHUB_TOKEN-}"

setup_suite() {
  cd "${REPO_FOLDER}"
  git init --quiet --initial-branch=master

  # unset it to make this test work
  unset GITHUB_TOKEN

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

  fake_gh() {
    # shellcheck disable=SC2317
    printf "%s\n" "${GITHUB_TOKEN-}"
    # shellcheck disable=SC2317,SC2154
    printf "%s\n" "${FAKE_PARAMS[@]}"
  }
  export -f fake_gh
  export GPG_NO_SIGN=1

  fake gh fake_gh
}

teardown_suite() {
  export GITHUB_TOKEN="${ORIGINAL_TOKEN}"

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

test_plugin_gh_0_1_initial_message_dryrun() {
  git commit --quiet -m "fix: initial commit" --allow-empty --no-gpg-sign

  GITHUB_TOKEN="FAKE_TOKEN" bash "${ROOT_DIR}/release.sh" --plugins=git,github-release --dry-run --quiet --pre-release
  assert_not_matches "v0.0.1" "$(git tag -l)"
}
test_plugin_gh_0_2_initial_message() {
  assert_matches "v0.0.1" "$(GITHUB_TOKEN="FAKE_TOKEN" bash "${ROOT_DIR}/release.sh" --plugins=git,github-release --quiet)"
  assert_matches "v0.0.1" "$(git tag -l)"
}
test_plugin_gh_no_token_fail_message() {
  git commit --quiet -m "fix: initial commit" --allow-empty --no-gpg-sign

  assert_matches "v0.0.1" "$(git tag -l)"
  assert_not_matches "v0.0.2" "$(git tag -l)"
  assert_status_code 1 "${ROOT_DIR}/release.sh --plugins=github-release --quiet"
}
test_plugin_z_check_gh() {
  unset gh
  unset fake_gh

  assert_status_code 1 "${ROOT_DIR}/release.sh --plugins=github-release --quiet"
}
