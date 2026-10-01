#!/usr/bin/env bash
set -eu

ROOT_DIR="$(realpath ../../)"
REPO_FOLDER=$(mktemp -d)

setup_suite() {
  cd "${REPO_FOLDER}"
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

  # shellcheck disable=SC2329
  _npm() {
    # shellcheck disable=SC2317,SC2154
    if [[ -n "${NPM_CALLS-}" ]]; then
      printf '%s\n' "${FAKE_PARAMS[*]}" >>"${NPM_CALLS}"
    fi
    if [[ "${FAKE_PARAMS[0]}" == "view" ]]; then
      # a failed lookup only means "not published"; it must not kill
      # the release shell, so return instead of exit
      [[ "${NPM_VIEW-}" == "published" ]]
      return
    fi
    if [[ "${FAKE_PARAMS[0]}" == "publish" && ("${NPM_TOKEN-}" == "FAKE_TOKEN" || "${ACTIONS_ID_TOKEN_REQUEST_TOKEN-}" == "FAKE_TOKEN") ]]; then
      return 0
    else
      exit 1
    fi
  }
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

test_plugin_npm_0_1_initial_message_dryrun() {
  git commit --quiet -m "fix: initial commit" --allow-empty --no-gpg-sign

  NPM_TOKEN="FAKE_TOKEN" bash "${ROOT_DIR}/release.sh" --plugins=npm,git --dry-run
  assert_matches "1.0.0" "$(cat package.json)"
}
test_plugin_npm_0_2_initial_message() {
  assert_matches "npm tag: v0.0.1 and version: v0.0.1" "$(NPM_TOKEN="FAKE_TOKEN" bash "${ROOT_DIR}/release.sh" --plugins=npm,git --verbose)"
  assert_matches "0.0.1" "$(cat package.json)"
}
test_plugin_npm_0_3_trusted_publishing_message() {
  git commit --quiet -m "fix: trusted publishing bump" --allow-empty --no-gpg-sign

  assert_matches "npm tag: v0.0.2 and version: v0.0.2" "$(ACTIONS_ID_TOKEN_REQUEST_TOKEN="FAKE_TOKEN" bash "${ROOT_DIR}/release.sh" --plugins=npm,git --verbose)"
  assert_matches "0.0.2" "$(cat package.json)"
}
test_plugin_npm_0_4_already_published_skips_publish() {
  git commit --quiet -m "fix: already published bump" --allow-empty --no-gpg-sign

  NPM_CALLS="${REPO_FOLDER}/npm-calls.log"
  export NPM_CALLS NPM_VIEW="published"
  assert_matches "already published to npm, skipping publish" \
    "$(NPM_TOKEN="FAKE_TOKEN" bash "${ROOT_DIR}/release.sh" --plugins=npm --verbose)"
  assert_matches "0.0.3" "$(cat package.json)"
  assert_matches "view" "$(cat "${NPM_CALLS}")"
  if grep -q "publish" "${NPM_CALLS}"; then
    fail "npm publish must not run when the version is already published"
  fi
  rm -rf "${NPM_CALLS}"
  unset NPM_CALLS NPM_VIEW
}
test_plugin_npm_no_pkg_fail_message() {
  git commit --quiet -m "fix: update commit" --allow-empty --no-gpg-sign

  rm -rf package.json
  assert_matches "Project does not have package.json" "$(NPM_TOKEN="FAKE_TOKEN" bash "${ROOT_DIR}/release.sh" --plugins=npm,git --verbose)"
  assert_status_code 1 "NPM_TOKEN=\"FAKE_TOKEN\" ${ROOT_DIR}/release.sh --plugins=npm,git --quiet"
}
