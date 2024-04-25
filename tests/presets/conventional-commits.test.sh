#!/usr/bin/env bash
set -eu

ROOT_DIR="$(realpath ../../)"
REPO_FOLDER=$(mktemp -d)

setup_suite() {
  cd "$REPO_FOLDER"
  git init --quiet --initial-branch=master

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
  git commit --quiet -m "fix: initial commit" --allow-empty

  bash "$ROOT_DIR/release.sh" --plugins=git --preset=conventional-commits --verbose
  assert_equals "v0.0.1" "$(git tag -l | tail -1)"
}
test_commit_0_2_initial_message_no_change() {

  assert_matches "Your project has no new commits" "$(bash "$ROOT_DIR/release.sh" --plugins=git --preset=conventional-commits)"
}
test_commit_0_3_skip_change() {
  git commit --quiet -m "chore: chore commit" --allow-empty

  bash "$ROOT_DIR/release.sh" --plugins=git --preset=conventional-commits --dry-run --pre-release --quiet
  assert_equals "v0.0.1" "$(git tag -l | tail -1)"

  bash "$ROOT_DIR/release.sh" --plugins=git --preset=conventional-commits --quiet
  assert_equals "v0.0.1" "$(git tag -l | tail -1)"
}
test_commit_1_0_stable_major_no_message() {
  git commit --quiet -m "fix: patch update" --allow-empty

  bash "$ROOT_DIR/release.sh" --plugins=git --quiet --stable
  assert_matches "v1.0.0" "$(git tag -l)"
}
test_commit_1_1_feat_breaking_major_message() {
  git commit --quiet -m "feat: allow provided config object to extend other configs" -m "BREAKING CHANGE: \`extends\` key in config file is now used for extending other config files" --allow-empty

  bash "$ROOT_DIR/release.sh" --plugins=git --quiet
  assert_matches "v2.0.0" "$(git tag -l)"
}
test_commit_2_feat_mark_major_message() {
  git commit --quiet -m "feat!: send an email to the customer when a product is shipped" --allow-empty

  bash "$ROOT_DIR/release.sh" --plugins=git --quiet --dry-run
  assert_matches "v2.0.0" "$(git tag -l)"

  assert_matches "v3.0.0" "$(bash "$ROOT_DIR/release.sh" --plugins=git --dry-run)"

  bash "$ROOT_DIR/release.sh" --plugins=git --quiet
  assert_matches "v3.0.0" "$(git tag -l)"
}
test_commit_3_feat_mark_scope_major_message() {
  git commit --quiet -m "feat(api)!: send an email to the customer when a product is shipped" --allow-empty

  bash "$ROOT_DIR/release.sh" --plugins=git --quiet --dry-run
  assert_matches "v3.0.0" "$(git tag -l)"

  bash "$ROOT_DIR/release.sh" --plugins=git --quiet
  assert_matches "v4.0.0" "$(git tag -l)"
}
test_commit_4_feat_mark_breaking_scope_major_message() {
  git commit --quiet -m "chore!: drop support for Node 6" -m "BREAKING CHANGE: use JavaScript features not available in Node 6." --allow-empty

  bash "$ROOT_DIR/release.sh" --plugins=git --quiet --dry-run
  assert_matches "v4.0.0" "$(git tag -l)"

  bash "$ROOT_DIR/release.sh" --plugins=git --quiet
  assert_matches "v5.0.0" "$(git tag -l)"
}
test_commit_5_docs_no_update_message() {
  git commit --quiet -m "docs: correct spelling of CHANGELOG" --allow-empty

  bash "$ROOT_DIR/release.sh" --plugins=git --dry-run
  assert_matches "v5.0.0" "$(git tag -l)"

  bash "$ROOT_DIR/release.sh" --plugins=git --quiet
  assert_matches "v5.0.0" "$(git tag -l)"
}
test_commit_6_feat_scope_message() {
  git commit --quiet -m "feat(lang): add Polish language" --allow-empty

  bash "$ROOT_DIR/release.sh" --plugins=git --quiet --dry-run
  assert_matches "v5.0.0" "$(git tag -l)"

  bash "$ROOT_DIR/release.sh" --plugins=git --quiet
  assert_matches "v5.1.0" "$(git tag -l)"
}
test_commit_7_fix_multi_message() {
  git commit --quiet -m "fix: prevent racing of requests" -m "Introduce a request id and a reference to latest request. Dismiss incoming responses other than from latest request." -m "Remove timeouts which were used to mitigate the racing issue but are obsolete now" -m "Reviewed-by: Z" -m "Refs: #123" --allow-empty

  bash "$ROOT_DIR/release.sh" --plugins=git --quiet --dry-run
  assert_matches "v5.1.0" "$(git tag -l)"

  bash "$ROOT_DIR/release.sh" --plugins=git --quiet
  assert_matches "v5.1.1" "$(git tag -l)"
}
test_commit_8_revert_message() {
  git commit --quiet -m "revert: let us never again speak of the noodle incident" -m "Refs: 676104e, a215868" --allow-empty

  bash "$ROOT_DIR/release.sh" --plugins=git --quiet --dry-run --verbose
  assert_matches "v5.1.1" "$(git tag -l)"

  bash "$ROOT_DIR/release.sh" --plugins=git
  assert_matches "v5.1.2" "$(git tag -l)"
}
