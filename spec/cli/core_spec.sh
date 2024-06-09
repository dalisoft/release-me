#!/bin/sh
set -eu

ROOT_DIR=$(realpath ./)
REPO_FOLDER=

Describe "cli"
  setup_suite() {
    REPO_FOLDER=$(mktemp -d)

    cd "${REPO_FOLDER}"
    git init --quiet --initial-branch=master

    export GIT_DIR="${REPO_FOLDER}/.git"
    export GIT_CONFIG="${REPO_FOLDER}/.gitconfig"
    export GIT_WORK_TREE="${REPO_FOLDER}"

    if [ -n "${GIT_USERNAME-}" ] && [ -n "${GIT_EMAIL-}" ]; then
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
  }

  BeforeEach 'setup_suite'
  AfterEach 'teardown_suite'

  It 'help argument'
    When call bash "${ROOT_DIR}/release.sh" --help
    The output should include "release"
    The status should be success
  End

  It 'version option'
    When call bash "${ROOT_DIR}/release.sh" --version
    The output should include "last version available at GitHub"
    The status should be success
  End

  It 'invalid option'
    When call "${ROOT_DIR}/release.sh" --invalid
    The output should include "Unknown option: --invalid"
    The status should be failure
  End

  It 'invalid argument'
    When call "${ROOT_DIR}/release.sh" invalid
    The output should include "Unknown argument: invalid"
    The status should be failure
  End

  It 'empty repo'
    When call "${ROOT_DIR}/release.sh"
    The output should include "You have not committed yet"
    The status should be failure
  End
End
