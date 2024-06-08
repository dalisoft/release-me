#!/usr/bin/env bash
set -eu

# RegExp as variable
regexp_commit_primary="^([a-z]+)(\(([^\)]+)\))?:\ (.+)$"
regexp_commit_major="^([a-z]+)(\(([^\)]+)\))?!?:\ (.+)$"
string_commit_major="^BREAKING CHANGE(: )?(.+)"

# Release types
RELEASE_SKIP_TYPES=("build" "chore" "style" "ci" "skip ci")
RELEASE_PATCH_TYPES=("fix" "close" "closes" "perf" "revert")
RELEASE_MINOR_TYPES=("refactor" "feat")
RELEASE_MAJOR_TYPES=("BREAKING CHANGE")

UNAFFECTED_TYPES=("test" "docs")
INCLUDE_SCOPE=("refactor" "perf" "revert")

CHANGELOG_STORE_UNCHANGED=()
CHANGELOG_STORE_PATCH=()
CHANGELOG_STORE_MINOR=()
CHANGELOG_STORE_MAJOR=()

# This function parses a single commit message
parse_commit() {
  local -n COMMIT_MSG="$1"

  local hash="${COMMIT_MSG[1]}"
  local sha256="${COMMIT_MSG[2]}"
  local subject="${COMMIT_MSG[3]}"
  local body="${COMMIT_MSG[5]}"

  local type
  local scope
  local description

  # Extracting the type, scope, and description using Bash regex
  if [[ "${subject}" =~ ${regexp_commit_primary} ]]; then
    type="${BASH_REMATCH[1]}"
    scope="${BASH_REMATCH[3]}"
    description="${BASH_REMATCH[4]}"

  elif [[ "${subject}" =~ ${regexp_commit_major} ]]; then
    type="BREAKING CHANGE"
    scope="${BASH_REMATCH[3]}"
    description="${BASH_REMATCH[4]}"
  else
    return 0
  fi

  # Early catching non-workspace commits
  if [[ "${scope-}" != "${PKG_NAME-}" ]]; then
    return 0
  fi

  # Extract body
  if [[ -n "${body}" && "${body}" =~ ${string_commit_major} ]]; then
    type="BREAKING CHANGE"
    description="${subject}"
  fi

  local line=""
  if is_valid_commit_type "${type}" "${INCLUDE_SCOPE[@]}"; then
    line+="- **${PKG_NAME}**: **\`[${type}]\`** ${description} "
  else
    line+="- **${PKG_NAME}**: ${description} "
  fi
  line+="([\`${hash}\`](https://github.com/${GIT_REPO_NAME-}/commit/${sha256}))"

  # Handle other type of commits
  if is_valid_commit_type "${type}" "${RELEASE_SKIP_TYPES[@]}"; then
    return 0
  elif is_valid_commit_type "${type}" "${RELEASE_PATCH_TYPES[@]}"; then
    if ! ${PATCH_UPGRADED}; then
      PATCH_UPGRADED=true
    fi
    CHANGELOG_STORE_PATCH+=("${line}")
  elif is_valid_commit_type "${type}" "${RELEASE_MINOR_TYPES[@]}"; then
    if ! ${MINOR_UPGRADED}; then
      MINOR_UPGRADED=true
    fi
    CHANGELOG_STORE_MINOR+=("${line}")
  elif is_valid_commit_type "${type}" "${RELEASE_MAJOR_TYPES[@]}"; then
    if ! ${MAJOR_UPGRADED}; then
      MAJOR_UPGRADED=true
    fi
    CHANGELOG_STORE_MAJOR+=("${line}")
  elif is_valid_commit_type "${type}" "${UNAFFECTED_TYPES[@]}"; then
    CHANGELOG_STORE_UNCHANGED+=("${line}")
  fi
}

build_release() {
  local IFS=$'\n'

  if [[ ${#CHANGELOG_STORE_MAJOR[@]} -gt 0 ]]; then
    RELEASE_BODY+="\n## BREAKING CHANGES\n"
    RELEASE_BODY+="${CHANGELOG_STORE_MAJOR[*]}"
  fi

  if [[ ${#CHANGELOG_STORE_MINOR[@]} -gt 0 ]]; then
    RELEASE_BODY+="\n## Features\n"
    RELEASE_BODY+="${CHANGELOG_STORE_MINOR[*]}"
  fi

  if [[ ${#CHANGELOG_STORE_PATCH[@]} -gt 0 ]]; then
    RELEASE_BODY+="\n## Bug Fixes\n"
    RELEASE_BODY+="${CHANGELOG_STORE_PATCH[*]}"
  fi

  if [[ ${#CHANGELOG_STORE_UNCHANGED[@]} -gt 0 ]]; then
    RELEASE_BODY+="\n## Other improvements\n"
    RELEASE_BODY+="${CHANGELOG_STORE_UNCHANGED[*]}"
  fi
}
