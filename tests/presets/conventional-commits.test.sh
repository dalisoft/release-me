#!/usr/bin/env bash
set -e

REPO_FOLDER=$(mktemp -d)

setup_suite() {
  cd "$REPO_FOLDER"
  git init --initial-branch=master

  export GIT_DIR="$REPO_FOLDER/.git"
  export GIT_CONFIG="$REPO_FOLDER/.gitconfig"
  export GIT_WORK_TREE="$REPO_FOLDER"

  if [[ -n "$GIT_USERNAME" && -n "$GIT_EMAIL" ]]; then
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

test_commit_1_1_feat_breaking_major_message() {
  git commit -m "feat: allow provided config object to extend other configs" -m "BREAKING CHANGE: \`extends\` key in config file is now used for extending other config files" --allow-empty --no-gpg-sign
  bash "$ROOT_DIR/release.sh" --plugins=git --quiet --stable

  assert_equals "v1.0.0" "$(git tag -l | tail -1)"
}
test_commit_1_2_feat_breaking_major_message_dryrun() {
  git commit -m "feat: allow provided config object to extend other configs" -m "BREAKING CHANGE: \`extends\` key in config file is now used for extending other config files" --allow-empty --no-gpg-sign
  bash "$ROOT_DIR/release.sh" --plugins=git --quiet --stable --dry-run

  assert_equals "v1.0.0" "$(git tag -l | tail -1)"
}
test_commit_2_1_feat_mark_major_message() {
  git commit -m "feat!: send an email to the customer when a product is shipped" --allow-empty --no-gpg-sign
  bash "$ROOT_DIR/release.sh" --plugins=git --quiet

  assert_equals "v2.0.0" "$(git tag -l | tail -1)"
}
test_commit_2_2_feat_mark_major_message_dryrun() {
  git commit -m "feat!: send an email to the customer when a product is shipped" --allow-empty --no-gpg-sign
  bash "$ROOT_DIR/release.sh" --plugins=git --quiet --dry-run

  assert_equals "v2.0.0" "$(git tag -l | tail -1)"
}
test_commit_3_1_feat_mark_scope_major_message() {
  git commit -m "feat(api)!: send an email to the customer when a product is shipped" --allow-empty --no-gpg-sign
  bash "$ROOT_DIR/release.sh" --plugins=git --quiet

  assert_equals "v3.0.0" "$(git tag -l | tail -1)"
}
test_commit_3_2_feat_mark_scope_major_message_dryrun() {
  git commit -m "feat(api)!: send an email to the customer when a product is shipped" --allow-empty --no-gpg-sign
  bash "$ROOT_DIR/release.sh" --plugins=git --quiet --dry-run

  assert_equals "v3.0.0" "$(git tag -l | tail -1)"
}
test_commit_4_1_feat_mark_breaking_scope_major_message() {
  git commit -m "chore!: drop support for Node 6" -m "BREAKING CHANGE: use JavaScript features not available in Node 6." --allow-empty --no-gpg-sign
  bash "$ROOT_DIR/release.sh" --plugins=git --quiet

  assert_equals "v4.0.0" "$(git tag -l | tail -1)"
}
test_commit_4_2_feat_mark_breaking_scope_major_message_dryrun() {
  git commit -m "chore!: drop support for Node 6" -m "BREAKING CHANGE: use JavaScript features not available in Node 6." --allow-empty --no-gpg-sign
  bash "$ROOT_DIR/release.sh" --plugins=git --quiet --dry-run

  assert_equals "v4.0.0" "$(git tag -l | tail -1)"
}
test_commit_5_1_docs_no_update_message() {
  git commit -m "docs: correct spelling of CHANGELOG" --allow-empty --no-gpg-sign
  bash "$ROOT_DIR/release.sh" --plugins=git --quiet

  assert_equals "v4.0.0" "$(git tag -l | tail -1)"
}
test_commit_5_2_docs_no_update_message_dryrun() {
  git commit -m "docs: correct spelling of CHANGELOG" --allow-empty --no-gpg-sign
  bash "$ROOT_DIR/release.sh" --plugins=git --quiet --dry-run

  assert_equals "v4.0.0" "$(git tag -l | tail -1)"
}
test_commit_6_1_feat_scope_message() {
  git commit -m "feat(lang): add Polish language" --allow-empty --no-gpg-sign

  bash "$ROOT_DIR/release.sh" --plugins=git --quiet

  assert_equals "v4.1.0" "$(git tag -l | tail -1)"
}
test_commit_6_2_feat_scope_message_dryrun() {
  git commit -m "feat(lang): add Polish language" --allow-empty --no-gpg-sign

  bash "$ROOT_DIR/release.sh" --plugins=git --quiet --dry-run

  assert_equals "v4.1.0" "$(git tag -l | tail -1)"
}
test_commit_7_1_fix_multi_message() {
  git commit -m "fix: prevent racing of requests" -m "Introduce a request id and a reference to latest request. Dismiss incoming responses other than from latest request." -m "Remove timeouts which were used to mitigate the racing issue but are obsolete now" -m "Reviewed-by: Z" -m "Refs: #123" --allow-empty --no-gpg-sign

  bash "$ROOT_DIR/release.sh" --plugins=git --quiet

  assert_equals "v4.1.1" "$(git tag -l | tail -1)"
}
test_commit_7_2_fix_multi_message_dryrun() {
  git commit -m "fix: prevent racing of requests" -m "Introduce a request id and a reference to latest request. Dismiss incoming responses other than from latest request." -m "Remove timeouts which were used to mitigate the racing issue but are obsolete now" -m "Reviewed-by: Z" -m "Refs: #123" --allow-empty --no-gpg-sign

  bash "$ROOT_DIR/release.sh" --plugins=git --quiet --dry-run

  assert_equals "v4.1.1" "$(git tag -l | tail -1)"
}
test_commit_8_1_revert_message() {
  git commit -m "revert: let us never again speak of the noodle incident" -m "Refs: 676104e, a215868" --allow-empty --no-gpg-sign

  bash "$ROOT_DIR/release.sh" --plugins=git --quiet

  assert_equals "v4.1.2" "$(git tag -l | tail -1)"
}
test_commit_8_2_revert_message_dryrun() {
  git commit -m "revert: let us never again speak of the noodle incident" -m "Refs: 676104e, a215868" --allow-empty --no-gpg-sign

  bash "$ROOT_DIR/release.sh" --plugins=git --quiet --dry-run

  assert_equals "v4.1.2" "$(git tag -l | tail -1)"
}
