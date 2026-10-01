#!/usr/bin/env bash
set -eu
shopt -s inherit_errexit

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

  git() {
    # shellcheck disable=SC2317
    if [[ "$1" == "push" ]]; then
      return 0
    elif [[ "$1" == "remote" ]]; then
      printf "%s" "https://github.com/dalisoft/release-me"
    else
      command git "$@"
    fi
  }
  export -f git
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

test_plugin_git_0_1_initial_message_dryrun() {
  git commit --quiet -m "fix: initial commit" --allow-empty --no-gpg-sign

  bash "${ROOT_DIR}/release.sh" --plugins=git --dry-run --verbose --pre-release
  assert_not_matches "v0.0.1" "$(git tag -l)"
}
test_plugin_git_0_2_initial_message() {
  assert_matches "v0.0.1" "$(bash "${ROOT_DIR}/release.sh" --plugins=git --verbose)"
  assert_matches "v0.0.1" "$(git tag -l)"
}
test_plugin_git_pull_rebase_divergent_remote() {
  unset -f git

  REMOTE_FOLDER=$(mktemp -d)
  env -u GIT_DIR -u GIT_WORK_TREE -u GIT_INDEX_FILE git init --quiet --bare "${REMOTE_FOLDER}/origin.git"
  git remote add origin "${REMOTE_FOLDER}/origin.git"
  git push --quiet -u origin master

  git commit --quiet -m "chore(ci): remote-side update" --allow-empty --no-gpg-sign
  git push --quiet origin master
  git reset --quiet --hard HEAD~1
  git commit --quiet -m "fix: divergent pull" --allow-empty --no-gpg-sign

  assert_status_code 0 "bash ${ROOT_DIR}/release.sh --plugins=git --verbose"
  assert_matches "chore\\(ci\\): remote-side update" "$(git log master --oneline)"
  assert_matches "v0\\.0\\.2" "$(git ls-remote --tags origin)"

  rm -rf "${REMOTE_FOLDER}"
}
