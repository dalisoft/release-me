#!/usr/bin/env bash
set -eu

ROOT_DIR="$(realpath ../../)"
REPO_FOLDER=$(mktemp -d)

setup_suite() {
  cd "${REPO_FOLDER}"
  git init --quiet --initial-branch=master

  echo '{
  "name": "events",
  "version": "0.0.0",
  "private": true,
  "description": "> Except bugs, errors and/or strange behavior",
  "main": "index.js",
  "license": "ISC"
}
' >>"${REPO_FOLDER}/package.json"

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

  git add package.json
  git commit --quiet -m "chore(events): initial commit" --no-gpg-sign
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

# Foreign and malformed tags must not leak into this package's
# last-tag lookup (issue #49: substring siblings, legacy
# `name@version`, scoped tags, malformed versions)
test_tag_0_noise_tags_ignored() {
  git commit --quiet -m "fix(events): first fix" --allow-empty --no-gpg-sign

  bash "${ROOT_DIR}/release.sh" --plugins=git --preset=workspace --workspace --quiet
  assert_matches "events-v0.0.1" "$(git tag -l)"

  git commit --quiet -m "chore: noise carrier" --allow-empty --no-gpg-sign
  git tag ws-events-sync-v1.0.0
  git tag events@0.5.0
  git tag events-v0.bad
  git tag @scope/events-v9.9.9

  git commit --quiet -m "fix(events): second fix" --allow-empty --no-gpg-sign

  bash "${ROOT_DIR}/release.sh" --plugins=git --preset=workspace --workspace --quiet
  assert_matches "events-v0.0.2" "$(git tag -l)"
}

test_tag_1_newest_malformed_tag_skipped() {
  git commit --quiet -m "chore: newer noise carrier" --allow-empty --no-gpg-sign
  git tag events-v1.x

  git commit --quiet -m "fix(events): third fix" --allow-empty --no-gpg-sign

  bash "${ROOT_DIR}/release.sh" --plugins=git --preset=workspace --workspace --quiet
  assert_matches "events-v0.0.3" "$(git tag -l)"
}
