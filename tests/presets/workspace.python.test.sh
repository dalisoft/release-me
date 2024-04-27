#!/usr/bin/env bash
set -eu

ROOT_DIR="$(realpath ../../)"
REPO_FOLDER=$(mktemp -d)

setup_suite() {
  cd "$REPO_FOLDER"
  git init --quiet --initial-branch=master

  echo 'from setuptools import setup, find_packages


setup(
    name="workspace1",
    version="0.0.0",
    packages=find_packages(),
)
' >>"$REPO_FOLDER/setup.py"

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
}

#####################################
## This tests of specification at  ##
## https://conventionalcommits.org ##
#####################################

test_commit_0_1_initial_message() {
  git commit --quiet -m "fix(workspace1): initial commit" --allow-empty --no-gpg-sign

  bash "$ROOT_DIR/release.sh" --plugins=git --preset=workspace --workspace --quiet
  assert_matches "workspace1-v0.0.1" "$(git tag -l)"
}
test_commit_0_2_invalid_workspace() {
  git commit --quiet -m "fix(workspace3): initial commit" --allow-empty --no-gpg-sign

  bash "$ROOT_DIR/release.sh" --plugins=git --preset=workspace --workspace --quiet
  assert_matches "workspace1-v0.0.1" "$(git tag -l)"
}
test_commit_0_2_initial_message_no_change() {

  assert_matches "Your project has no new commits" "$(bash "$ROOT_DIR/release.sh" --plugins=git --preset=workspace --workspace)"
}
test_commit_0_3_skip_change() {
  git commit --quiet -m "chore(workspace1): chore commit" --allow-empty --no-gpg-sign

  bash "$ROOT_DIR/release.sh" --plugins=git --preset=workspace --workspace --dry-run --pre-release --quiet
  assert_matches "workspace1-v0.0.1" "$(git tag -l)"

  bash "$ROOT_DIR/release.sh" --plugins=git --preset=workspace --workspace --quiet
  assert_matches "workspace1-v0.0.1" "$(git tag -l)"
}
test_commit_1_0_stable_major_no_message() {
  git commit --quiet -m "fix(workspace1): patch update" --allow-empty --no-gpg-sign

  bash "$ROOT_DIR/release.sh" --plugins=git --preset=workspace --workspace --stable --quiet
  assert_matches "workspace1-v1.0.0" "$(git tag -l)"
}
test_commit_1_1_feat_breaking_major_message() {
  git commit --quiet -m "feat(workspace1): allow provided config object to extend other configs" -m "BREAKING CHANGE: \`extends\` key in config file is now used for extending other config files" --allow-empty --no-gpg-sign

  bash "$ROOT_DIR/release.sh" --plugins=git --preset=workspace --workspace --quiet
  assert_matches "workspace1-v2.0.0" "$(git tag -l)"
}
test_commit_1_1_feat_breaking_major_message_skip() {
  git commit --quiet -m "feat(workspace2): allow provided config object to extend other configs" -m "BREAKING CHANGE: \`extends\` key in config file is now used for extending other config files" --allow-empty --no-gpg-sign

  bash "$ROOT_DIR/release.sh" --plugins=git --preset=workspace --workspace --quiet
  assert_matches "workspace1-v2.0.0" "$(git tag -l)"
}
test_commit_2_feat_mark_major_message() {
  git commit --quiet -m "feat!: send an email to the customer when a product is shipped" --allow-empty --no-gpg-sign

  bash "$ROOT_DIR/release.sh" --plugins=git --preset=workspace --workspace --quiet
  assert_matches "workspace1-v2.0.0" "$(git tag -l)"

  assert_matches "Your project has no new commits" "$(bash "$ROOT_DIR/release.sh" --plugins=git --preset=workspace --workspace --dry-run)"

  bash "$ROOT_DIR/release.sh" --plugins=git --preset=workspace --workspace --quiet
  assert_matches "workspace1-v2.0.0" "$(git tag -l)"
}
test_commit_3_feat_mark_scope_major_message() {
  git commit --quiet -m "feat(workspace1)!: send an email to the customer when a product is shipped" --allow-empty --no-gpg-sign

  bash "$ROOT_DIR/release.sh" --plugins=git --preset=workspace --workspace --dry-run --quiet
  assert_matches "workspace1-v2.0.0" "$(git tag -l)"

  bash "$ROOT_DIR/release.sh" --plugins=git --preset=workspace --workspace --quiet
  assert_matches "workspace1-v3.0.0" "$(git tag -l)"
}
test_commit_4_feat_mark_breaking_scope_major_message() {
  git commit --quiet -m "chore(workspace1)!: drop support for Node 6" -m "BREAKING CHANGE: use JavaScript features not available in Node 6." --allow-empty --no-gpg-sign

  bash "$ROOT_DIR/release.sh" --plugins=git --preset=workspace --workspace --dry-run --quiet
  assert_matches "workspace1-v3.0.0" "$(git tag -l)"

  bash "$ROOT_DIR/release.sh" --plugins=git --preset=workspace --workspace --quiet
  assert_matches "workspace1-v4.0.0" "$(git tag -l)"
}
test_commit_5_docs_root_no_update_message() {
  git commit --quiet -m "docs: correct spelling of CHANGELOG" --allow-empty --no-gpg-sign

  bash "$ROOT_DIR/release.sh" --plugins=git --preset=workspace --workspace --dry-run --quiet
  assert_matches "workspace1-v4.0.0" "$(git tag -l)"

  bash "$ROOT_DIR/release.sh" --plugins=git --preset=workspace --workspace --quiet
  assert_matches "workspace1-v4.0.0" "$(git tag -l)"
}
test_commit_5_docs_workspace_no_update_message() {
  git commit --quiet -m "docs(workspace1): correct spelling of CHANGELOG" --allow-empty --no-gpg-sign

  bash "$ROOT_DIR/release.sh" --plugins=git --preset=workspace --workspace --dry-run --quiet
  assert_matches "workspace1-v4.0.0" "$(git tag -l)"

  bash "$ROOT_DIR/release.sh" --plugins=git --preset=workspace --workspace --quiet
  assert_matches "workspace1-v4.0.0" "$(git tag -l)"
}
test_commit_6_feat_scope_message() {
  git commit --quiet -m "feat(workspace1): add Polish language" --allow-empty --no-gpg-sign

  bash "$ROOT_DIR/release.sh" --plugins=git --preset=workspace --workspace --dry-run --quiet
  assert_matches "workspace1-v4.0.0" "$(git tag -l)"

  bash "$ROOT_DIR/release.sh" --plugins=git --preset=workspace --workspace --quiet
  assert_matches "workspace1-v4.1.0" "$(git tag -l)"
}
test_commit_6_feat_scope_message_passwordless() {
  unset GPG_KEY_ID
  unset GPG_PASSPHRASE
  unset GPG_KEY

  export GPG_KEY_ID="${GPG_KEY_ID_UNSAFE-}"
  export GPG_KEY="${GPG_KEY_UNSAFE-}"
  export GPG_PASSPHRASE=

  git commit --quiet -m "feat(workspace1): add Polish language" --allow-empty --no-gpg-sign

  bash "$ROOT_DIR/release.sh" --plugins=git --preset=workspace --workspace --dry-run --quiet
  assert_matches "workspace1-v4.1.0" "$(git tag -l)"

  bash "$ROOT_DIR/release.sh" --plugins=git --preset=workspace --workspace --quiet
  assert_matches "workspace1-v4.2.0" "$(git tag -l)"
}
test_commit_7_fix_multi_message() {
  git commit --quiet -m "fix(workspace1): prevent racing of requests" -m "Introduce a request id and a reference to latest request. Dismiss incoming responses other than from latest request." -m "Remove timeouts which were used to mitigate the racing issue but are obsolete now" -m "Reviewed-by: Z" -m "Refs: #123" --allow-empty --no-gpg-sign

  bash "$ROOT_DIR/release.sh" --plugins=git --preset=workspace --workspace --dry-run --quiet
  assert_matches "workspace1-v4.2.0" "$(git tag -l)"

  bash "$ROOT_DIR/release.sh" --plugins=git --preset=workspace --workspace --quiet
  assert_matches "workspace1-v4.2.1" "$(git tag -l)"
}
test_commit_8_revert_message() {
  git commit --quiet -m "revert(workspace1): let us never again speak of the noodle incident" -m "Refs: 676104e, a215868" --allow-empty --no-gpg-sign

  bash "$ROOT_DIR/release.sh" --plugins=git --preset=workspace --workspace --dry-run --verbose
  assert_matches "workspace1-v4.2.1" "$(git tag -l)"

  bash "$ROOT_DIR/release.sh" --plugins=git --preset=workspace --workspace
  assert_matches "workspace1-v4.2.2" "$(git tag -l)"
}

test_commit_9_merge_message() {
  git commit --quiet -m "Merge pull request #6 from dalisoft/release-me" -m "FIX tests" --allow-empty --no-gpg-sign

  bash "$ROOT_DIR/release.sh" --plugins=git --preset=workspace --workspace
  assert_matches "v4.2.2" "$(git tag -l)"
}
test_commit_a_10_invalid_message() {
  git commit --quiet -m "FIX tests" --allow-empty --no-gpg-sign

  bash "$ROOT_DIR/release.sh" --plugins=git --preset=workspace --workspace
  assert_matches "v4.2.2" "$(git tag -l)"
}
test_commit_a_11_invalid_scope() {
  git commit --quiet -m "hotkey(workspace1): it may work?" --allow-empty --no-gpg-sign

  bash "$ROOT_DIR/release.sh" --plugins=git --preset=workspace --workspace
  assert_matches "v4.2.2" "$(git tag -l)"
}
test_commit_a_12_invalid_scope_and_pkg() {
  git commit --quiet -m "hotkey(workspace3): it may work?" --allow-empty --no-gpg-sign

  bash "$ROOT_DIR/release.sh" --plugins=git --preset=workspace --workspace
  assert_matches "v4.2.2" "$(git tag -l)"
}
test_commit_a_13_invalid_package_name() {
  git commit --quiet -m "feat(workspace3): it may work?" --allow-empty --no-gpg-sign

  bash "$ROOT_DIR/release.sh" --plugins=git --preset=workspace --workspace
  assert_matches "v4.2.2" "$(git tag -l)"
}
