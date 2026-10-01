#!/usr/bin/env bash
set -eu

ROOT_DIR="$(realpath ../../)"
REPO_FOLDER=$(mktemp -d)

setup_suite() {
  cd "${REPO_FOLDER}"
  git init --quiet --initial-branch=master

  echo '{
  "name": "@nanoexpress/workspace1",
  "version": "0.0.0",
  "private": true,
  "description": "> Except bugs, errors and/or strange behavior",
  "main": "index.js",
  "directories": {
    "doc": "docs",
    "test": "tests"
  },
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "publishConfig": {
    "dry-run": true
  },
  "keywords": [],
  "author": "",
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

  _npm() {
    # shellcheck disable=SC2317,SC2154
    if [[ "${FAKE_PARAMS[0]}" == "publish" && "${NPM_TOKEN-}" == "FAKE_TOKEN" ]]; then
      return 0
    else
      exit 1
    fi
  }

  export NPM_TOKEN="FAKE_TOKEN"
  export -f _npm

  fake npm _npm
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

test_scoped_tag_1_next_version_from_existing_scoped_tag() {
  git commit --quiet -m "feat(@nanoexpress/workspace1): initial commit" --allow-empty --no-gpg-sign
  git tag "@nanoexpress/workspace1-v0.0.9"

  git commit --quiet -m "fix(@nanoexpress/workspace1): parse scoped tags" --allow-empty --no-gpg-sign

  GPG_NO_SIGN=1 bash "${ROOT_DIR}/release.sh" --plugins=npm,git --preset=workspace --workspace --quiet
  assert_matches "@nanoexpress/workspace1-v0.0.10" "$(git tag -l)"
}

test_scoped_tag_2_minor_bump_after_scoped_tag() {
  git commit --quiet -m "feat(@nanoexpress/workspace1): add scoped tag support" --allow-empty --no-gpg-sign

  GPG_NO_SIGN=1 bash "${ROOT_DIR}/release.sh" --plugins=npm,git --preset=workspace --workspace --quiet
  assert_matches "@nanoexpress/workspace1-v0.1.0" "$(git tag -l)"
}
