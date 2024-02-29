#!/usr/bin/env bash
set -e

PROJECT_DIR=$(pwd)
REPO_FOLDER=$(mktemp -d)

setup_suite() {
  cd "$REPO_FOLDER"
  git init --initial-branch=master

  export GIT_DIR="$REPO_FOLDER/.git"
  export GIT_WORK_TREE="$REPO_FOLDER"

  if [[ -n "$GIT_USERNAME" && -n "$GIT_EMAIL" ]]; then
    export GIT_COMMITTER_NAME="$GIT_USERNAME"
    export GIT_COMMITTER_EMAIL="$GIT_EMAIL"
    export GIT_AUTHOR_NAME="$GIT_USERNAME"
    export GIT_AUTHOR_EMAIL="$GIT_EMAIL"

    git config --local user.email "$GIT_EMAIL"
    git config --local user.name "$GIT_USERNAME"
  fi
}

teardown_suite() {
  cd "$PROJECT_DIR"

  rm -rf "$GIT_WORK_TREE"
  unset REPO_FOLDER
  unset GIT_DIR
  unset GIT_WORK_TREE
}

#####################################
## This tests of specification at  ##
## https://conventionalcommits.org ##
#####################################

test_commit_1_feat_breaking_major_message() {
  git commit -m "feat: allow provided config object to extend other configs" -m "BREAKING CHANGE: \`extends\` key in config file is now used for extending other config files" --allow-empty --no-gpg-sign
  bash "$PROJECT_DIR/../../release.sh" --plugins=git --stable

  assert_equals "v1.0.0" "$(git tag -l | tail -1)"
}
test_commit_2_feat_mark_major_message() {
  git commit -m "feat!: send an email to the customer when a product is shipped" --allow-empty --no-gpg-sign
  bash "$PROJECT_DIR/../../release.sh" --plugins=git

  assert_equals "v2.0.0" "$(git tag -l | tail -1)"
}
test_commit_3_feat_mark_scope_major_message() {
  git commit -m "feat(api)!: send an email to the customer when a product is shipped" --allow-empty --no-gpg-sign
  bash "$PROJECT_DIR/../../release.sh" --plugins=git

  assert_equals "v3.0.0" "$(git tag -l | tail -1)"
}
test_commit_4_feat_mark_breaking_scope_major_message() {
  git commit -m "chore!: drop support for Node 6" -m "BREAKING CHANGE: use JavaScript features not available in Node 6." --allow-empty --no-gpg-sign
  bash "$PROJECT_DIR/../../release.sh" --plugins=git

  assert_equals "v4.0.0" "$(git tag -l | tail -1)"
}
test_commit_5_docs_no_update_message() {
  git commit -m "docs: correct spelling of CHANGELOG" --allow-empty --no-gpg-sign
  bash "$PROJECT_DIR/../../release.sh" --plugins=git

  assert_equals "v4.0.0" "$(git tag -l | tail -1)"
}
test_commit_6_feat_scope_message() {
  git commit -m "feat(lang): add Polish language" --allow-empty --no-gpg-sign

  bash "$PROJECT_DIR/../../release.sh" --plugins=git

  assert_equals "v4.1.0" "$(git tag -l | tail -1)"
}
