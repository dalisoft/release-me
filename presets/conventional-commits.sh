#!/bin/bash
set -euo pipefail

# RegExp as variable
regexp_commit_primary="^([a-z]+)(\(([^\)]+)\))?:\ (.+)$"
regexp_commit_major="^([a-z]+)(\(([^\)]+)\))?!?:\ (.+)$"
string_commit_major="^BREAKING CHANGE"

# Release types
RELEASE_SKIP_TYPES=("build" "chore" "docs" "test" "style" "ci" "skip ci")
RELEASE_PATCH_TYPES=("fix" "close" "closes" "perf" "revert")
RELEASE_MINOR_TYPES=("refactor" "feat")
RELEASE_MAJOR_TYPES=("BREAKING CHANGE")

INCLUDE_SCOPE=("refactor" "perf" "revert")

# This function parses a single commit message
parse_commit() {
  local subject="$1"
  local hash="$2"
  local sha256="$3"

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

  if is_valid_commit_type "$type" "${RELEASE_SKIP_TYPES[@]}"; then
    return 0
  elif is_valid_commit_type "$type" "${RELEASE_PATCH_TYPES[@]}"; then
    if ! $PATCH_UPGRADED; then
      PATCH_UPGRADED=true
      RELEASE_BODY+="\n## Bug Fixes\n\n"
    fi
  elif is_valid_commit_type "$type" "${RELEASE_MINOR_TYPES[@]}"; then
    if ! $MINOR_UPGRADED; then
      MINOR_UPGRADED=true
      RELEASE_BODY+="\n## Features\n\n"
    fi
  elif is_valid_commit_type "$type" "${RELEASE_MAJOR_TYPES[@]}"; then
    if ! $MAJOR_UPGRADED; then
      MAJOR_UPGRADED=true
      RELEASE_BODY+="\n## BREAKING CHANGES\n\n"
    fi
  fi

  RELEASE_BODY+="- "
  if is_valid_commit_type "$type" "${INCLUDE_SCOPE[@]}"; then
    RELEASE_BODY+="**\`[$type]\`** "
  fi

  if [ -n "${scope-}" ]; then
    RELEASE_BODY+="**$scope**: "
  fi
  RELEASE_BODY+="$description "
  RELEASE_BODY+="([\`$hash\`](https://github.com/$GIT_REPO_NAME/commit/$sha256))\n"
}
