#!/usr/bin/env bash
set -e

readonly RELEASE_ME_VERSION="0.0.1"
readonly USAGE="Usage: release-me [options]
An zero-dependency single-file shell script which does all the work of semantic-release with it's GitHub and npm plugin and it's so fast

Options:
  -d, --dry-run   Dry run. Skip tag creation, only show logs (if exists).
  -w, --workspace Use in workspace environment for publishing workspaces separately.
  -h, --help      Show this help.
  -v, --version   Show version.
"

##############################
####### Root variables #######
##############################
CURRENT_DATE=$(date +'%Y-%m-%d')
GIT_LOG_ENTRY_SEPARATOR='__'
GIT_LOG_SEPARATOR='++++'
GIT_LOG_FORMAT="$GIT_LOG_SEPARATOR%s$GIT_LOG_ENTRY_SEPARATOR%h$GIT_LOG_ENTRY_SEPARATOR%H"
#GIT_LOG_FORMAT+="$GIT_LOG_SEPARATOR%(trailers:only=true)$GIT_LOG_ENTRY_SEPARATOR%h$GIT_LOG_ENTRY_SEPARATOR%H"
GIT_REPO_NAME=$(git remote get-url origin | cut -d ':' -f 2 | sed s/.git//)

IS_WORKSPACE=false
IS_DRY_RUN=false
IS_VERBOSE=false
PLUGINS=("git")
PRESET=""

##############################
###### Helpers & Utils #######
##############################

function parseOptions {
  while :; do
    local KEY="$1"
    case $KEY in
    -v | --version)
      echo "release-me: ${RELEASE_ME_VERSION}"
      exit 0
      ;;
    -h | -\? | --help)
      echo "$USAGE"
      exit 0
      ;;
    -w | --workspace)
      IS_WORKSPACE=true
      ;;
    --plugins=*)
      local IFS=','
      read -ra PLUGINS <<<"${KEY#*=}"
      ;;
    --preset=*)
      local IFS=','
      read -r PRESET <<<"${KEY#*=}"
      ;;
    -d | --dry-run)
      # shellcheck disable=2034
      IS_DRY_RUN=true
      ;;
    --verbose)
      IS_VERBOSE=true
      ;;
    -?*)
      echo "Unknown option: $KEY" >&2
      echo "$USAGE"
      exit 1
      ;;
    ?*)
      echo "Unknown argument: $KEY" >&2
      echo "$USAGE"
      exit 1
      ;;
    "")
      break
      ;;
    esac
    shift
  done
}

function isValidCommitType {
  local key="$1"
  shift
  local arr=("$@")

  for element in "${arr[@]}"; do
    local elementDynamic=$element

    if $IS_WORKSPACE; then
      elementDynamic="${element}(${PKG_NAME})"
    else
      elementDynamic="${element}"
    fi

    if [[ "$key" == "$elementDynamic"* ]]; then
      return 0
    fi
  done
  return 1
}

##############################
##### Early exit errors ######
##############################

parseOptions "$@"

# Release types
# shellcheck disable=2034
RELEASE_SKIP_TYPES=("build" "chore" "docs" "test" "style" "ci" "skip ci")
# shellcheck disable=2034
RELEASE_PATCH_TYPES=("fix" "close" "closes" "perf" "revert")
# shellcheck disable=2034
RELEASE_MINOR_TYPES=("refactor" "feat")
# shellcheck disable=2034
RELEASE_MAJOR_TYPES=("BREAKING CHANGE")

##############################
##### Package variables ######
##############################

PKG_NAME=""
SEMANTIC_VERSION=(0 0 0)
SEMANTIC_VERSION_COPY=(0 0 0)

function parsePackages {
  if ! $IS_WORKSPACE; then
    return 0
  fi

  if [ -f "./package.json" ]; then
    PKG_NAME=$(awk -F': ' '/"name":/ {gsub(/[",]/, "", $2); print $2}' "./package.json")
  elif [ -f "./Cargo.toml" ]; then
    PKG_NAME=$(sed -n 's/^name = "\(.*\)"/\1/p' "./Cargo.toml")
  elif [ -f "./setup.py" ]; then
    PKG_NAME=$(sed -n 's/^setup(\s*name\s*=\s*["'\'']\([^"'\'']*\)["'\''].*/\1/p' "./setup.py")
  else
    cat <<EOF
This project currently supports only Node.js, Rust and Python projects.
Please wait for updates to get support in other languages!
EOF
    exit 1
  fi
}

##############################
####### Git variables ########
##############################

GIT_LAST_PROJECT_TAG=""

function getGitVariables {
  if $IS_WORKSPACE; then
    GIT_LAST_PROJECT_TAG=$(git for-each-ref --sort=creatordate --format '%(refname)' refs/tags | grep "$PKG_NAME" | tail -1 | cut -d '/' -f 3)
  else
    GIT_LAST_PROJECT_TAG=$(git for-each-ref --sort=creatordate --format '%(refname)' refs/tags | tail -1 | cut -d '/' -f 3)
  fi

  # GIT_CURRENT_TAG="${PKG_NAME}-v${PKG_VERSION}"
  # GIT_IS_TAG_EXISTS=$(git show-ref --tags --verify --quiet "refs/tags/${GIT_CURRENT_TAG}")

  if [[ $GIT_LAST_PROJECT_TAG != "" ]]; then
    GIT_LAST_PROJECT_TAG_VER=$(echo "$GIT_LAST_PROJECT_TAG" | rev | cut -d 'v' -f 1 | rev)
  fi

  mapfile -d '.' -t SEMANTIC_VERSION < <(printf '%s' "$GIT_LAST_PROJECT_TAG_VER")
  SEMANTIC_VERSION_COPY=("${SEMANTIC_VERSION[@]}")
}

##############################
######## Git handling ########
##############################

COMMITS=()

function getGitCommits {
  # Check if exists last tag and is not empty
  if [ "$GIT_LAST_PROJECT_TAG" != "" ]; then
    # Get and cache commits variable, so later
    # can be checked for commits length and avaibality
    if $IS_WORKSPACE; then
      mapfile -d $GIT_LOG_SEPARATOR -t COMMITS < <(git log "$GIT_LAST_PROJECT_TAG...HEAD" --grep "$PKG_NAME" --pretty=format:"$GIT_LOG_FORMAT" --reverse)
    else
      mapfile -d $GIT_LOG_SEPARATOR -t COMMITS < <(git log "$GIT_LAST_PROJECT_TAG..HEAD" --pretty=format:"$GIT_LOG_FORMAT" --reverse)
    fi
  else
    if $IS_WORKSPACE; then
      mapfile -d $GIT_LOG_SEPARATOR -t COMMITS < <(git log HEAD --grep "$PKG_NAME" --pretty=format:"$GIT_LOG_FORMAT" --reverse)
    else
      mapfile -d $GIT_LOG_SEPARATOR -t COMMITS < <(git log HEAD --pretty=format:"$GIT_LOG_FORMAT" --reverse)
    fi
  fi

  if [[ "${#COMMITS[*]}" -eq 0 ]]; then
    echo "Your repository is up-to-date"
    exit 0
  fi
}

##############################
#### Git commits handling ####
##############################
BUILD_VERSION=""
RELEASE_TAG_NAME=""
RELEASE_BODY=""

PATCH_UPGRADED=false
MINOR_UPGRADED=false
MAJOR_UPGRADED=false

function handleGitCommits {

  for COMMIT in "${COMMITS[@]}"; do
    local IFS="$GIT_LOG_ENTRY_SEPARATOR"
    read -r -a COMMIT_ARRAY <<<"${COMMIT}"

    if [ "$PRESET" != "" ]; then
      local SOURCE_PRESET_FILE="presets/${PRESET}.sh"
      # shellcheck disable=SC1090
      source "$SOURCE_PRESET_FILE"
      if [ "$(command -v parse_commit)" ]; then
        parse_commit COMMIT_ARRAY
      fi
      unset parse_commit
    fi
  done

  if $MAJOR_UPGRADED; then
    SEMANTIC_VERSION[0]=$((SEMANTIC_VERSION[0] + 1))
    SEMANTIC_VERSION[1]=0
    SEMANTIC_VERSION[2]=0
  elif $MINOR_UPGRADED; then
    SEMANTIC_VERSION[1]=$((SEMANTIC_VERSION[1] + 1))
    SEMANTIC_VERSION[2]=0
  elif $PATCH_UPGRADED; then
    SEMANTIC_VERSION[2]=$((SEMANTIC_VERSION[1] + 1))
  fi

  BUILD_VERSION=$(
    IFS='.'
    echo -n "${SEMANTIC_VERSION[*]}"
  )
  PREV_BUILD_VERSION=$(
    IFS='.'
    echo -n "${SEMANTIC_VERSION_COPY[*]}"
  )

  RELEASE_PREV_TAG_NAME=""

  if $IS_WORKSPACE; then
    RELEASE_TAG_NAME="${PKG_NAME}-v${BUILD_VERSION}"
    RELEASE_PREV_TAG_NAME="${PKG_NAME}-v${PREV_BUILD_VERSION}"
  else
    RELEASE_TAG_NAME="v${BUILD_VERSION}"
    RELEASE_PREV_TAG_NAME="v${PREV_BUILD_VERSION}"
  fi

  if [ -n "$GIT_LAST_PROJECT_TAG_VER" ]; then
    RELEASE_DIFF_URL="https://github.com/$GIT_REPO_NAME/compare/${RELEASE_PREV_TAG_NAME}...$RELEASE_TAG_NAME"
    RELEASE_BODY_TITLE="[$RELEASE_TAG_NAME]($RELEASE_DIFF_URL) ($CURRENT_DATE)"
  else
    RELEASE_BODY_TITLE="$RELEASE_TAG_NAME ($CURRENT_DATE)"
  fi

  RELEASE_BODY="# $RELEASE_BODY_TITLE\n$RELEASE_BODY"
}

##############################
######## Handle push ########
##############################

function handlePushes {

  local IFS="$GIT_LOG_ENTRY_SEPARATOR"
  read -r -a COMMIT_ARRAY <<<"${COMMITS[-1]}"
  # shellcheck disable=2034
  CHECKOUT_SHA=${COMMIT_ARRAY[4]}

  for plugin in "${PLUGINS[@]}"; do
    local SOURCE_PLUGIN_FILE="plugins/${plugin}.sh"
    # shellcheck disable=SC1090
    source "$SOURCE_PLUGIN_FILE"
    if [ "$(command -v release)" ]; then
      release
    fi
    unset release
  done
}

##############################
######## Initializate ########
##############################
parsePackages
getGitVariables
getGitCommits
handleGitCommits
handlePushes

if $IS_VERBOSE; then
  echo "Release tag: $RELEASE_TAG_NAME"
  echo "Release title: $RELEASE_BODY_TITLE"
  echo -e "Release body: $RELEASE_BODY"
fi
