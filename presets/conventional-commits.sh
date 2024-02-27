#!/usr/bin/env bash
set -e

# RegExp as variable
regexp_commit_primary="^([a-z]+)(\(([^\)]+)\))?:\ (.+)$"
regexp_commit_major="^([a-z]+)(\(([^\)]+)\))?!?:\ (.+)$"
string_commit_major="^BREAKING CHANGE"

# Release types
# shellcheck disable=2034
RELEASE_SKIP_TYPES=("build" "chore" "docs" "test" "style" "ci" "skip ci")
# shellcheck disable=2034
RELEASE_PATCH_TYPES=("fix" "close" "closes" "perf" "revert")
# shellcheck disable=2034
RELEASE_MINOR_TYPES=("refactor" "feat")
# shellcheck disable=2034
RELEASE_MAJOR_TYPES=("BREAKING CHANGE")

INCLUDE_SCOPE=("refactor" "perf" "revert")

# This function parses a single commit message
parse_commit() {
  local -n COMMIT_MSG="$1"

  local subject="${COMMIT_MSG[0]}"
  local hash="${COMMIT_MSG[1]}"
  local sha256="${COMMIT_MSG[2]}"

  local type
  local scope
  local description

  # Extracting the type, scope, and description using Bash regex
  if [[ "$subject" =~ $regexp_commit_primary ]]; then
    type="${BASH_REMATCH[1]}"
    scope="${BASH_REMATCH[3]}"
    description="${BASH_REMATCH[4]}"

  elif [[ "$subject" =~ $regexp_commit_major ]]; then
    # type="${BASH_REMATCH[1]}"
    scope="${BASH_REMATCH[3]}"
    description="${BASH_REMATCH[4]}"

    type="BREAKING CHANGE"
  elif [[ "$subject" =~ $string_commit_major ]]; then
    type="BREAKING CHANGE"

    description="$subject"
  else
    return 0
  fi

  if isValidCommitType "$type" "${RELEASE_SKIP_TYPES[@]}"; then
    return 0
  elif isValidCommitType "$type" "${RELEASE_PATCH_TYPES[@]}"; then
    if ! $PATCH_UPGRADED; then
      PATCH_UPGRADED=true
      RELEASE_BODY+="\n## Bug Fixes\n\n"
    fi
  elif isValidCommitType "$type" "${RELEASE_MINOR_TYPES[@]}"; then
    if ! $MINOR_UPGRADED; then
      MINOR_UPGRADED=true
      RELEASE_BODY+="\n## Features\n\n"
    fi
  elif isValidCommitType "$type" "${RELEASE_MAJOR_TYPES[@]}"; then
    if ! $MAJOR_UPGRADED; then
      MAJOR_UPGRADED=true
      RELEASE_BODY+="\n## BREAKING CHANGES\n\n"
    fi
  fi

  RELEASE_BODY+="- "
  if isValidCommitType "$type" "${INCLUDE_SCOPE[@]}"; then
    RELEASE_BODY+="**\`[$type]\`** "
  fi
  if [ -n "$scope" ]; then
    RELEASE_BODY+="**$scope**: "
  fi
  RELEASE_BODY+="$description "
  RELEASE_BODY+="([\`$hash\`](https://github.com/$GIT_REPO_NAME/commit/$sha256))\n"
}
