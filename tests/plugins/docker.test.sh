#!/usr/bin/env bash
set -eu

ROOT_DIR="$(realpath ../../)"
REPO_FOLDER=$(mktemp -d)
ORIGINAL_DOCKER_TOKEN="${DOCKER_HUB_PAT-}"

setup_suite() {

  cd "$REPO_FOLDER"
  git init --quiet --initial-branch=master

  # unset it to make this test work
  unset DOCKER_HUB_PAT

  echo 'FROM alpine:latest

RUN apk add --no-cache bash git
RUN mkdir -p /repository

VOLUME [ "/repository" ]
WORKDIR /repository

ADD release.sh presets plugins /repository/
RUN chmod +x /repository/release.sh

ENTRYPOINT [ "/repository/release.sh" ]
CMD [ "--help" ]
' >>"$REPO_FOLDER/Dockerfile"

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

  _docker() {
    # shellcheck disable=SC2317
    if [[ -z "${DOCKER_HUB_PAT-}" ]]; then
      exit 1
    elif [[ "${FAKE_PARAMS[0]}" == "build" || "${FAKE_PARAMS[0]}" == "push" ]]; then
      return 0
    else
      exit 1
    fi
  }
  export -f _docker

  fake docker _docker
}

teardown_suite() {
  export DOCKER_HUB_PAT="$ORIGINAL_DOCKER_TOKEN"

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

test_plugin_docker_0_1_initial_message_dryrun() {
  git commit --quiet -m "fix: initial commit" --allow-empty --no-gpg-sign

  DOCKER_HUB_PAT="FAKE_TOKEN" bash "$ROOT_DIR/release.sh" --plugins=docker --dry-run
}
test_plugin_docker_0_2_initial_message() {
  assert_matches "Docker tag: v0.0.1 and version: v0.0.1" "$(DOCKER_HUB_PAT="FAKE_TOKEN" bash "$ROOT_DIR/release.sh" --plugins=docker --verbose)"
}
test_plugin_docker_no_dockerfile_fail_message() {
  git commit --quiet -m "fix: update commit" --allow-empty --no-gpg-sign

  rm -rf Dockerfile
  assert_matches "Project does not have Dockerfile" "$(DOCKER_HUB_PAT="FAKE_TOKEN" bash -eu "$ROOT_DIR/release.sh" --plugins=docker --verbose)"
  assert_status_code 1 "DOCKER_HUB_PAT=\"FAKE_TOKEN\" $ROOT_DIR/release.sh --plugins=docker --verbose"
}
test_plugin_docker_no_token_fail_message() {
  git commit --quiet -m "fix: update commit" --allow-empty --no-gpg-sign

  assert_status_code 1 "$ROOT_DIR/release.sh --plugins=docker --verbose"
}
