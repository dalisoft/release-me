#!/bin/sh
set -eu

ROOT_DIR=$(realpath ./)
REPO_FOLDER=

Describe "no-git"
  setup_suite() {
    REPO_FOLDER=$(mktemp -d)
    cd "${REPO_FOLDER}"
  }

  teardown_suite() {
    rm -rf "${REPO_FOLDER}"
  }

  BeforeEach 'setup_suite'
  AfterEach 'teardown_suite'

  It 'no repo'
    When call bash "${ROOT_DIR}/release.sh" --plugins=PLUGIN_TEMPLATE
    The output should include "Current directory is not a Git repository!"
    The status should be failure
  End
End
