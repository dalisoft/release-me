#!/usr/bin/env bash
set -e

function parsePackages {
  if ! $IS_WORKSPACE; then
    return 0
  fi
}

function isValidCommitType {
  local key="$1"
  shift
  local arr=("$@")

  for element in "${arr[@]}"; do
    if [[ "$key" == "${element}"* ]]; then
      return 0
    fi
  done
  return 1
}

function handleGitCommit {
  local -n COMMIT_MSG="$1"

  local COMMIT_HEADER="${COMMIT_MSG[0]}"
  local COMMIT_HASH="${COMMIT_MSG[2]}"
  local COMMIT_SHA="${COMMIT_MSG[4]}"

  # echo -e "commit"
  # echo -e "${COMMIT_MSG[@]}"
  # echo -e "end commit"

  for i in "${!COMMIT_MSG[@]}"; do
    if [[ $i -lt 5 || ${COMMIT_MSG[i]} == "" ]]; then
      continue
    fi
    # read -d '\n' -r -a COMMITES <<<"${COMMIT_MSG[i]}"
    mapfile -d '\n' -t COMMITES < <(printf '%s' "${COMMIT_MSG[i]}")

    for commit in "${COMMITES[@]}"; do
      # shellcheck disable=SC2034
      local REF_ARRAY=("$commit" "" "$COMMIT_HASH" "" "$COMMIT_SHA")
      handleGitCommit REF_ARRAY
    done

    return 0
  done

  if isValidCommitType "$COMMIT_HEADER" "${RELEASE_SKIP_TYPES[@]}"; then
    return 0
  elif isValidCommitType "$COMMIT_HEADER" "${RELEASE_PATCH_TYPES[@]}"; then
    if ! $PATCH_UPGRADED; then
      PATCH_UPGRADED=true
      RELEASE_BODY+="\n## Bug Fixes\n\n"
    fi
    RELEASE_BODY+="- $COMMIT_MSG ([\`$COMMIT_HASH\`](https://github.com/$GIT_REPO_NAME/commit/$COMMIT_SHA))\n"
  elif isValidCommitType "$COMMIT_HEADER" "${RELEASE_MINOR_TYPES[@]}"; then
    if ! $MINOR_UPGRADED; then
      MINOR_UPGRADED=true
      RELEASE_BODY+="\n## Features\n\n"
    fi

    RELEASE_BODY+="- $COMMIT_MSG ([\`$COMMIT_HASH\`](https://github.com/$GIT_REPO_NAME/commit/$COMMIT_SHA))\n"
  elif isValidCommitType "$COMMIT_HEADER" "${RELEASE_MAJOR_TYPES[@]}"; then
    if ! $MAJOR_UPGRADED; then
      MAJOR_UPGRADED=true
      RELEASE_BODY+="\n## BREAKING CHANGES\n\n"
    fi

    RELEASE_BODY+="- $COMMIT_MSG ([\`$COMMIT_HASH\`](https://github.com/$GIT_REPO_NAME/commit/$COMMIT_SHA))\n"
  fi
}
