#!/bin/env bash
set -e

##############################
##### Early exit errors ######
##############################

if [ "$1" == "--dry-run" ]; then
  cat <<EOF
\`--dry-run\` is not support at the moment

Please wait for update or use script on local fake repos only
EOF
  exit 1
fi

if [ "$GH_TOKEN" == "" ]; then
  cat <<EOF
GH_TOKEN is not available

Please specify GH_TOKEN variable so you can use
this script without issues
EOF
  exit 1
fi

##############################
####### Root variables #######
##############################
EXEC_DIR=$(dirname $0)
CURRENT_DATE=$(date +F%)

##############################
###### Function helpers ######
##############################

# semantic-versioning parser function
function parsePackageVersion() {
  echo "ver?: $0; $1; $2"

  local SEMANTIC_VERSION=()

  IFS='.' read -a VERSION <<<"$1"

  echo "${VERSION[@]}"

  for ver in "${VERSION[@]}"; do
    echo "version: $ver"
  done

  echo "$1"
}

##############################
##### Package variables ######
##############################
PKG_NAME=$(cat "./package.json" | sed -n 's/^[[:space:]]*"name": "\(.*\)",/\1/p')
PKG_VERSION=$(cat "./package.json" | sed -n 's/^[[:space:]]*"version": "\(.*\)",/\1/p')
VERSION=$(parsePackageVersion "$PKG_VERSION")

##############################
####### Git variables ########
##############################
GIT_LAST_ANY_TAG=$(git describe --tags --abbrev=0)
GIT_LAST_PROJECT_TAGS=$(git for-each-ref --sort=creatordate --format '%(refname) %(creatordate)' refs/tags | grep "$PKG_NAME" | tail -4 | cut -d ' ' -f 1 | cut -d '/' -f 3)
GIT_LAST_PROJECT_TAG=$(echo "$GIT_LAST_PROJECT_TAGS" | tail -1)
GIT_CURRENT_TAG="${PKG_NAME}-v${PKG_VERSION}"

# Global variables
GIT_IS_TAG_EXISTS=$(git show-ref --tags --verify --quiet "refs/tags/${GIT_CURRENT_TAG}")
PKG_GIT_COMMITS=$(git log -n1 --grep "$PKG_NAME" --pretty=format:%s)
PKG_LAST_TAG_COMMIT=$(git describe --tags --abbrev=0)

# Check if exists last tag and is not empty
if [ "$GIT_LAST_PROJECT_TAG" != "" ]; then
  # Get and cache commits variable, so later
  # can be checked for commits length and avaibality
  COMMITS=$(git log $GIT_LAST_PROJECT_TAG..HEAD --grep $PKG_NAME --pretty=format:'%s (%H)')

  # If commits are empty and length is less than 0,
  # we check it into previous tags for project
  # since we know it already exists
  if [ ${#COMMITS} -lt 1 ]; then
    # Re-fetch and re-assign variables to later usage
    GIT_LAST_PROJECT_TAG=$(echo "$GIT_LAST_PROJECT_TAGS" | tail -2 | head -1)
    COMMITS=$(git log $GIT_LAST_PROJECT_TAG..HEAD --grep $PKG_NAME --pretty=format:'%s (%H)')
  fi
fi

echo "$COMMITS" | sort -r -k1 | while read PKG_GIT_COMMIT; do
  echo "${PKG_GIT_COMMIT}"

  if [[ "$PKG_GIT_COMMIT" == "fix"* ]]; then
    VERSION[2]="${VERSION[2]}"
  fi
done
