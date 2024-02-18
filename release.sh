#!/usr/bin/env bash
set -e

readonly CLI_PREFIX="[release-me]"
readonly DESCRIPTION="Blazing fast minimal semantic-release alternative written-in Bash script with it's GitHub and npm plugins and presets support"
readonly USAGE="$CLI_PREFIX Usage: release-me [options]
$DESCRIPTION

Options:
  -d, --dry-run   Dry run. Skip tag creation, only show logs (if exists).
  -w, --workspace Use in workspace environment for publishing workspaces separately.
  --verbose       Verbose mode, shows more detailed logs
  --quiet         Quiet mode, shows less logs than default behavior
  --plugins=*     Plugins option for loading plugins [Required]
  --presets=*     Presets option for parsing commits [Required]
  --quiet         Quiet mode, shows less logs than default behavior
  -h, --help      Show this help.
  -v, --version   Show version.
"

##############################
####### Root variables #######
##############################
SCRIPT_DIR=$(dirname -- "$(readlink -f -- "$0")")
CURRENT_DATE=$(date +'%Y-%m-%d')
GIT_LOG_ENTRY_SEPARATOR='%n'
GIT_LOG_FORMAT="%s$GIT_LOG_ENTRY_SEPARATOR%h$GIT_LOG_ENTRY_SEPARATOR%H"
#GIT_LOG_FORMAT+="%(trailers:only=true)$GIT_LOG_ENTRY_SEPARATOR%h$GIT_LOG_ENTRY_SEPARATOR%H"
GIT_REPO_NAME=$(git remote get-url origin | cut -d ':' -f 2 | sed s/.git//)

IS_WORKSPACE=false
IS_DRY_RUN=false
IS_QUIET=false
IS_VERBOSE=false
PLUGINS=("git")
PRESET="conventional-commits"

# set `verbose` on `CI`
if [ "$CI" == true ]; then
  IS_VERBOSE=true
fi

##############################
###### Helpers & Utils #######
##############################

# proper handling of lines counter
# as `grep -c '^'` fails if there nothing
# and `wc -l` if there 1 commit
# so this utility was made

glc() {
  local input="$1"

  if [[ -p /dev/stdin ]]; then
    input="$(cat -)"
  else
    input="${*}"
  fi

  local COUNT=0
  while read -r line; do
    if [ -n "$line" ]; then
      COUNT=$((COUNT + 1))
    fi
  done <<<"$input"

  echo -n $COUNT
}

function parseOptions {
  while :; do
    local KEY="$1"
    case $KEY in
    -v | --version)
      echo "$CLI_PREFIX last version available at GitHub"
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
      read -r PRESET <<<"${KEY#*=}"
      ;;
    -d | --dry-run)
      # shellcheck disable=2034
      IS_DRY_RUN=true
      ;;
    -q | --quiet)
      IS_QUIET=true
      ;;
    --verbose)
      IS_VERBOSE=true
      # export GIT_TRACE=1
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
    if [[ "$key" == "${element}"* ]]; then
      return 0
    fi
  done
  return 1
}

##############################
##### Logging helpers #######
##############################
log() {
  if ! $IS_QUIET; then
    if [ "$2" == "-q" ]; then
      echo -e "$1"
    else
      echo -e "$CLI_PREFIX $1"
    fi
  fi
}
log_verbose() {
  if $IS_VERBOSE; then
    if [ "$2" == "-q" ]; then
      echo -e "$1"
    else
      echo -e "$CLI_PREFIX $1"
    fi
  fi
}

##############################
##### Early exit errors ######
##############################

parseOptions "$@"

up_to_date() {
  log "$CLI_PREFIX $1" -q
  echo "$CLI_PREFIX Your project is up-to-date"
  exit 0
}

if [ "$PRESET" != "" ]; then
  SOURCE_PRESET_FILE="$SCRIPT_DIR/presets/${PRESET}.sh"
  # shellcheck disable=SC1090
  source "$SOURCE_PRESET_FILE"
fi

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

  log_verbose "Workspace mode is enabled"
  log_verbose "Workspace project name: $PKG_NAME"
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

  if [[ $GIT_LAST_PROJECT_TAG != "" ]]; then
    GIT_LAST_PROJECT_TAG_VER=$(echo "$GIT_LAST_PROJECT_TAG" | rev | cut -d 'v' -f 1 | rev)
  fi

  if [ -n "$GIT_LAST_PROJECT_TAG_VER" ]; then
    mapfile -d '.' -t SEMANTIC_VERSION < <(printf '%s' "$GIT_LAST_PROJECT_TAG_VER")
    SEMANTIC_VERSION_COPY=("${SEMANTIC_VERSION[@]}")
  fi
}

##############################
######## Git handling ########
##############################

GIT_LOGS=""

function getGitCommits {
  local IFS=
  local GIT_LOGS_LENGTH=0
  # Check if exists last tag and is not empty
  if [ -n "$GIT_LAST_PROJECT_TAG" ]; then
    log_verbose "Last project tag [$GIT_LAST_PROJECT_TAG] found"
    # Get and cache commits variable, so later
    # can be checked for commits length and avaibality
    if $IS_WORKSPACE; then
      GIT_LOGS=$(git log "$GIT_LAST_PROJECT_TAG...HEAD" --grep "$PKG_NAME" --pretty=format:"$GIT_LOG_FORMAT" --reverse)
      GIT_LOGS_LENGTH=$(git log "$GIT_LAST_PROJECT_TAG...HEAD" --grep "$PKG_NAME" --pretty=format:"%s" | glc -)
    else
      GIT_LOGS=$(git log "$GIT_LAST_PROJECT_TAG...HEAD" --pretty=format:"$GIT_LOG_FORMAT" --reverse)
      GIT_LOGS_LENGTH=$(git rev-list --no-merges --count "$GIT_LAST_PROJECT_TAG...HEAD")
    fi
  else
    log_verbose "Last project tag not found"
    if $IS_WORKSPACE; then
      GIT_LOGS=$(git log HEAD --grep "$PKG_NAME" --pretty=format:"$GIT_LOG_FORMAT" --reverse)
      GIT_LOGS_LENGTH=$(git log HEAD --grep "$PKG_NAME" --pretty=format:"%s" | glc -)
    else
      GIT_LOGS=$(git log HEAD --pretty=format:"$GIT_LOG_FORMAT" --reverse)
      GIT_LOGS_LENGTH=$(git rev-list --no-merges --count "$GIT_LAST_PROJECT_TAG...HEAD")
    fi
  fi

  if [[ $GIT_LOGS_LENGTH -eq 0 ]]; then
    up_to_date "Your project has no new commits"
  else
    if [ -n "$GIT_LAST_PROJECT_TAG" ]; then
      log_verbose "Found $GIT_LOGS_LENGTH commits since last release"
    else
      log_verbose "Found $GIT_LOGS_LENGTH commits but did not found any release"
    fi
  fi
}

##############################
#### Git commits handling ####
##############################
BUILD_VERSION=""
RELEASE_VERSION=""
RELEASE_TAG_NAME=""
RELEASE_BODY=""

PATCH_UPGRADED=false
MINOR_UPGRADED=false
MAJOR_UPGRADED=false

function handleGitCommits {
  log_verbose "Analyzing commits...\n"
  local IFS=
  while read -r subject && read -r hash && read -r sha256; do
    # shellcheck disable=SC2034
    local COMMIT_ARRAY=("$subject" "$hash" "$sha256")

    log_verbose "$subject" "-q"

    if [ "$(command -v parse_commit)" ]; then
      parse_commit COMMIT_ARRAY
    fi
  done <<<"$GIT_LOGS"
  log_verbose "" "-q"
  log_verbose "Analyzed commits!"

  log_verbose "Analyzing updates..."
  if $MAJOR_UPGRADED; then
    SEMANTIC_VERSION[0]=$((SEMANTIC_VERSION[0] + 1))
    SEMANTIC_VERSION[1]=0
    SEMANTIC_VERSION[2]=0
  elif $MINOR_UPGRADED; then
    SEMANTIC_VERSION[1]=$((SEMANTIC_VERSION[1] + 1))
    SEMANTIC_VERSION[2]=0
  elif $PATCH_UPGRADED; then
    SEMANTIC_VERSION[2]=$((SEMANTIC_VERSION[2] + 1))
  fi

  BUILD_VERSION=$(
    IFS='.'
    echo -n "${SEMANTIC_VERSION[*]}"
  )
  PREV_BUILD_VERSION=$(
    IFS='.'
    echo -n "${SEMANTIC_VERSION_COPY[*]}"
  )

  if [ "$BUILD_VERSION" == "$PREV_BUILD_VERSION" ]; then
    up_to_date "Your project has no incremental update"
  else
    log_verbose "Analyzing updates done!"
  fi

  RELEASE_PREV_TAG_NAME=""

  if $IS_WORKSPACE; then
    RELEASE_VERSION="v${BUILD_VERSION}"
    RELEASE_TAG_NAME="${PKG_NAME}-${RELEASE_VERSION}"
    RELEASE_PREV_TAG_NAME="${PKG_NAME}-v${PREV_BUILD_VERSION}"
  else
    RELEASE_VERSION="v${BUILD_VERSION}"
    RELEASE_TAG_NAME="${RELEASE_VERSION}"
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
  log_verbose "Applying changes..."

  CHECKOUT_SHA=$(echo "$GIT_LOGS" | tail -1)

  log_verbose "Found tag commit [$CHECKOUT_SHA]"

  for plugin in "${PLUGINS[@]}"; do
    log_verbose "Loading plugin \`$plugin\`..."
    local SOURCE_PLUGIN_FILE="$SCRIPT_DIR/plugins/${plugin}.sh"
    # shellcheck disable=SC1090
    source "$SOURCE_PLUGIN_FILE"
    if [ "$(command -v release)" ]; then
      release
    fi
    unset release
    log_verbose "Applied plugin $plugin!"
  done

  log_verbose "Applied changes!"
}

##############################
######## Initializate ########
##############################
parsePackages
getGitVariables
getGitCommits
handleGitCommits
handlePushes
