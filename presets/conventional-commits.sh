#!/usr/bin/env bash
set -e

# RegExp as variable
regexp_commit_primary="^([a-z]+)(\(([^\)]+)\))?:\ (.+)$"
regexp_commit_major="^([a-z]+)(\(([^\)]+)\))?!:\ (.+)$"
string_commit_major="^BREAKING CHANGE"

# separators
git_log_commit_separator='____'

parse_packages() {
  if ! $IS_WORKSPACE; then
    return 0
  fi
}

is_valid_commit_type() {
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

# This function parses a single commit message
parse_commit() {

  local IFS="$git_log_commit_separator"
  read -r -a commit <<<$(echo "$1" | sed s/++++//)
  local hash="${commit[0]}"
  local sha256="${commit[1]}"
  local subject="${commit[2]}"

  echo "${commit[@]}"

  local type
  local scope
  local description

  local response=()

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

  response[0]="$type"

  if [ -n "$scope" ]; then
    response[1]="$scope"
  else
    response[1]=""
  fi

  response[2]="$description"
  response[3]="$hash"
  response[4]="$sha256"

  printf -v response_string "%s$git_log_commit_separator" "${response[@]}"
  # To remove the trailing separator, we use parameter expansion
  response_string=${response_string%"$git_log_commit_separator"}

  echo "${response_string}"
}

while IFS='++++' read -r line; do
  parse_commit "$line"
done <"${1:-/dev/stdin}"
