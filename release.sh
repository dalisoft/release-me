#!/usr/bin/env bash
set -eu
shopt -s inherit_errexit

readonly CLI_PREFIX="[release-me]"
readonly DESCRIPTION="Fast minimal release workflow script written in Bash with plugins and presets support"
readonly USAGE="${CLI_PREFIX} Usage: release-me [options]
${DESCRIPTION}

Options:
  -d, --dry-run   Dry run. Skip tag creation, only show logs (if exists).
  -w, --workspace Use in workspace environment for publishing workspaces separately.
  --use-version   Use project version from manifest. Requires workspace and a valid manifest.
  --verbose       Verbose mode, shows more detailed logs.
  --quiet         Quiet mode, shows less logs than default behavior.
  --plugins=*     Plugins option for loading plugins.
  --preset=       Presets option for parsing commits.
  --stable        If project has a \`0.x\` version, it will bump to \`1.x\`.
  --pre-release   Mark project release as non-production ready.
  -h, --help      Show this help.
  -v, --version   Show version.
"

##############################
####### Root variables #######
##############################
READLINK=$(readlink -f -- "$0")
SCRIPT_DIR=$(dirname -- "${READLINK}")
CURRENT_DATE=$(date +'%Y-%m-%d')
IS_GIT_REPO=$(git rev-parse --is-inside-work-tree 2>/dev/null || printf "%s" "")
GIT_LOG_ENTRY_SEPARATOR='____'
GIT_LOG_COMMIT_SEPARATOR='START_OF_COMMIT'
GIT_LOG_FORMAT="${GIT_LOG_COMMIT_SEPARATOR}%n%h${GIT_LOG_ENTRY_SEPARATOR}%H${GIT_LOG_ENTRY_SEPARATOR}%s${GIT_LOG_ENTRY_SEPARATOR}%b"
GIT_LOG_PARSE_REGEX="(.*)${GIT_LOG_ENTRY_SEPARATOR}(.*)${GIT_LOG_ENTRY_SEPARATOR}(.*)(${GIT_LOG_ENTRY_SEPARATOR}(.*)?)"
GIT_REMOTE_ORIGIN=$(git remote get-url origin 2>/dev/null || printf "%s" "")
GIT_REPO_NAME=

if [[ "${GIT_REMOTE_ORIGIN}" == "git@"* ]]; then
  GIT_REPO_NAME=$(git remote get-url origin | cut -d ':' -f 2 | sed s/.git//)
elif [[ "${GIT_REMOTE_ORIGIN}" == "https"* ]]; then
  GIT_REPO_NAME=$(git remote get-url origin | cut -d ':' -f 2 | sed s/\\/\\/github.com\\///)
fi

IS_WORKSPACE=false
IS_USE_PKG_VERSION=false
IS_DRY_RUN=false
IS_QUIET=false
IS_VERBOSE=false
IS_STABLE_VERSION=false
PRE_RELEASE_VERSION=false
PLUGINS=("git")
PRESET="conventional-commits"

# set `verbose` on `CI`
if [[ -n "${CI:-}" ]]; then
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
  local COUNT=0
  while read -r line; do
    if [[ -n "${line}" ]]; then
      COUNT=$((COUNT + 1))
    fi
  done <<<"$(cat /dev/stdin)"

  printf "%s" "${COUNT}"
}

parse_options() {
  while :; do
    local KEY="${1-}"
    case "${KEY}" in
    -v | --version)
      printf "%s" "${CLI_PREFIX} last version available at GitHub"
      exit 0
      ;;
    -h | -\? | --help)
      printf "%s" "${USAGE}"
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
    --stable)
      IS_STABLE_VERSION=true
      PRE_RELEASE_VERSION=false
      ;;
    --pre-release)
      # shellcheck disable=2034
      PRE_RELEASE_VERSION=true
      IS_STABLE_VERSION=false
      ;;
    --use-version)
      IS_USE_PKG_VERSION=true
      ;;
    -d | --dry-run)
      # shellcheck disable=2034
      IS_DRY_RUN=true
      ;;
    -q | --quiet)
      IS_QUIET=true
      IS_VERBOSE=false
      ;;
    --verbose)
      IS_VERBOSE=true
      IS_QUIET=false
      # export GIT_TRACE=1
      ;;
    -?*)
      printf "%s" "${CLI_PREFIX} Unknown option: ${KEY}"
      exit 1
      ;;
    ?*)
      printf "%s" "${CLI_PREFIX} Unknown argument: ${KEY}"
      exit 1
      ;;
    *)
      break
      ;;
    esac
    shift
  done
}

is_valid_commit_type() {
  local key="$1"
  shift
  local arr=("$@")

  for element in "${arr[@]}"; do
    if [[ "${key}" == "${element}"* ]]; then
      return 0
    fi
  done
  return 1
}

##############################
##### Logging helpers #######
##############################
log() {
  if ! ${IS_QUIET}; then
    if [[ "${2-}" == "-q" ]]; then
      printf "%b\n" "$1"
    else
      printf "%b\n" "${CLI_PREFIX} $1"
    fi
  fi
}
log_verbose() {
  if ${IS_VERBOSE}; then
    if [[ "${2-}" == "-q" ]]; then
      printf "%b\n" "$1"
    else
      printf "%b\n" "${CLI_PREFIX} $1"
    fi
  fi
}

##############################
##### Early exit errors ######
##############################

if [[ "${IS_GIT_REPO}" != true ]]; then
  log "Current directory is not a Git repository!"
  exit 1
fi

parse_options "$@"

up_to_date() {
  log "${CLI_PREFIX} $1" -q
  printf "%s\n" "${CLI_PREFIX} Your project is up-to-date"
  exit 0
}

if [[ "${PRESET}" != "" ]]; then
  SOURCE_PRESET_FILE="${SCRIPT_DIR}/presets/${PRESET}.sh"
  # shellcheck disable=SC1090 source=/dev/null
  source "${SOURCE_PRESET_FILE}"
fi

##############################
##### Package variables ######
##############################

PKG_NAME=""
NEXT_VERSION=(0 0 0)
CURRENT_VERSION=(0 0 0)

parse_packages() {
  if ! ${IS_WORKSPACE}; then
    return 0
  fi

  if [[ -f "./package.json" ]]; then
    PKG_NAME=$(awk -F': ' '/"name":/ {gsub(/[",]/, "", $2); print $2}' "./package.json")
    if ${IS_USE_PKG_VERSION}; then
      PKG_VERSION=$(awk -F': ' '/"version":/ {gsub(/[",]/, "", $2); print $2}' "./package.json")
    fi
  elif [[ -f "./Cargo.toml" ]]; then
    PKG_NAME=$(sed -n 's/^name = "\(.*\)"/\1/p' "./Cargo.toml")
    if ${IS_USE_PKG_VERSION}; then
      PKG_VERSION=$(sed -n 's/^version = "\(.*\)"/\1/p' "./Cargo.toml")
    fi
  elif [[ -f "./setup.py" ]]; then
    PKG_NAME=$(sed -n "s/.*name=['\"]\([^'\"]*\)['\"].*/\1/p" "./setup.py")
    if ${IS_USE_PKG_VERSION}; then
      PKG_VERSION=$(sed -n 's/^ *version\s*=\s*["'\'']\([^"'\'']*\)["'\''].*/\1/p' "./setup.py")
    fi
  else
    cat <<EOF
This project currently supports only Node.js, Rust and Python projects.
Please wait for updates to get support in other languages!
EOF
    exit 1
  fi

  if ${IS_WORKSPACE} && [[ -z "${PKG_NAME}" ]]; then
    cat <<EOF
This release aims to being workspace release
but missing name and could not be release
EOF
    exit 1
  fi

  if ${IS_USE_PKG_VERSION}; then
    local IFS='.'
    read -ra NEXT_VERSION <<<"${PKG_VERSION}"
    CURRENT_VERSION=("${NEXT_VERSION[@]}")
  fi

  log_verbose "Workspace mode is enabled"
  log_verbose "Workspace project name: ${PKG_NAME}"
}

##############################
####### Git variables ########
##############################

GIT_LAST_PROJECT_TAG=""
GIT_LAST_PROJECT_TAG_VER=""

get_git_variables() {
  GIT_TAGS_LIST=$(git for-each-ref --sort=creatordate --format '%(refname)' refs/tags)

  if ${IS_WORKSPACE}; then
    GIT_LAST_PROJECT_TAG=$(printf "%b" "${GIT_TAGS_LIST}" | grep "${PKG_NAME}" | tail -1 | cut -d '/' -f 3)
  else
    GIT_LAST_PROJECT_TAG=$(printf "%s" "${GIT_TAGS_LIST}" | tail -1 | cut -d '/' -f 3)
  fi

  if [[ ${GIT_LAST_PROJECT_TAG} != "" ]]; then
    GIT_LAST_PROJECT_TAG_VER=$(printf "%s" "${GIT_LAST_PROJECT_TAG}" | rev | cut -d 'v' -f 1 | rev)
  fi

  if [[ -n "${GIT_LAST_PROJECT_TAG_VER}" ]]; then
    if ! ${IS_USE_PKG_VERSION}; then
      mapfile -d '.' -t NEXT_VERSION < <(printf '%s' "${GIT_LAST_PROJECT_TAG_VER}")
      CURRENT_VERSION=("${NEXT_VERSION[@]}")
    fi

    if [[ "${IS_STABLE_VERSION}" == false && ${PRE_RELEASE_VERSION} == false && "${NEXT_VERSION[0]}" -gt 0 ]]; then
      IS_STABLE_VERSION=true
    fi
  fi
}

##############################
######## Git handling ########
##############################

GIT_LOGS=""

get_git_commits() {
  local IFS=
  local GIT_LOGS_LENGTH=0

  # Fast early-catch empty repository
  if ! git rev-parse HEAD 1>/dev/null 2>&1; then
    log "You have not committed yet
You have to commit your initial/first commit."
    exit 1
  fi

  # Check if exists last tag and is not empty
  if [[ -n "${GIT_LAST_PROJECT_TAG}" ]]; then
    log_verbose "Last project tag [${GIT_LAST_PROJECT_TAG}] found"
    # Get and cache commits variable, so later
    # can be checked for commits length and avaibality
    if ${IS_WORKSPACE}; then
      GIT_LOGS=$(git log "${GIT_LAST_PROJECT_TAG}...HEAD" --grep "${PKG_NAME}" --pretty=format:"${GIT_LOG_FORMAT}" --reverse)
      GIT_LOGS_LENGTH=$(git log "${GIT_LAST_PROJECT_TAG}...HEAD" --grep "${PKG_NAME}" --pretty=format:"%s" | glc -)
    else
      GIT_LOGS=$(git log "${GIT_LAST_PROJECT_TAG}...HEAD" --pretty=format:"${GIT_LOG_FORMAT}" --reverse)
      GIT_LOGS_LENGTH=$(git rev-list --count "${GIT_LAST_PROJECT_TAG}...HEAD")
    fi
  else
    log_verbose "Last project tag not found"
    if ${IS_WORKSPACE}; then
      GIT_LOGS=$(git log HEAD --grep "${PKG_NAME}" --pretty=format:"${GIT_LOG_FORMAT}" --reverse)
      GIT_LOGS_LENGTH=$(git log HEAD --grep "${PKG_NAME}" --pretty=format:"%s" | glc -)
    else
      GIT_LOGS=$(git log HEAD --pretty=format:"${GIT_LOG_FORMAT}" --reverse)
      GIT_LOGS_LENGTH=$(git rev-list --count HEAD)
    fi
  fi

  if [[ ${GIT_LOGS_LENGTH} -eq 0 ]]; then
    up_to_date "Your project has no new commits"
  else
    if [[ -n "${GIT_LAST_PROJECT_TAG}" ]]; then
      log_verbose "Found ${GIT_LOGS_LENGTH} commits since last release"
    else
      log_verbose "Found ${GIT_LOGS_LENGTH} commits but did not found any release"
    fi
  fi
}

##############################
#### Git commits handling ####
##############################
NEXT_BUILD_VERSION=""
NEXT_RELEASE_VERSION=""
NEXT_RELEASE_TAG=""
RELEASE_BODY=""

PATCH_UPGRADED=false
MINOR_UPGRADED=false
MAJOR_UPGRADED=false

handle_git_commits() {
  log_verbose "Analyzing commits...\n"

  local IFS=
  while read -r line; do
    if [[ "${line}" == "${GIT_LOG_COMMIT_SEPARATOR}" ]]; then
      read -r commit

      if [[ "${commit}" =~ ${GIT_LOG_PARSE_REGEX} ]]; then
        log_verbose "${BASH_REMATCH[3]}" "-q"
        CHECKOUT_SHA=${BASH_REMATCH[1]}

        preset_command=$(command -v parse_commit)
        if [[ -n "${preset_command}" ]]; then
          parse_commit BASH_REMATCH
        fi
      fi
    fi
  done <<<"${GIT_LOGS}"
  log_verbose "" "-q"
  log_verbose "Analyzed commits!"

  log_verbose "Preparing changes diff..."
  build_release
  log_verbose "Prepared changes diff!"

  log_verbose "Analyzing updates..."
  if [[ "${IS_STABLE_VERSION}" == true && "${NEXT_VERSION[0]}" -eq 0 ]]; then
    NEXT_VERSION=(1 0 0)
  elif [[ ${MAJOR_UPGRADED} == true && "${NEXT_VERSION[0]}" -gt 0 ]]; then
    NEXT_VERSION[0]=$((NEXT_VERSION[0] + 1))
    NEXT_VERSION[1]=0
    NEXT_VERSION[2]=0
  elif ${MINOR_UPGRADED} || [[ ${MAJOR_UPGRADED} == true && "${NEXT_VERSION[0]}" -eq 0 ]]; then
    NEXT_VERSION[1]=$((NEXT_VERSION[1] + 1))
    NEXT_VERSION[2]=0
  elif ${PATCH_UPGRADED}; then
    NEXT_VERSION[2]=$((NEXT_VERSION[2] + 1))
  fi

  local IFS='.'
  NEXT_BUILD_VERSION="${NEXT_VERSION[*]}"
  CURRENT_BUILD_VERSION="${CURRENT_VERSION[*]}"

  if [[ "${NEXT_BUILD_VERSION}" == "${CURRENT_BUILD_VERSION}" ]]; then
    up_to_date "Your project has no incremental update"
  else
    log_verbose "Analyzing updates done!"
  fi

  CURRENT_RELEASE_TAG=""

  if ${IS_WORKSPACE}; then
    NEXT_RELEASE_VERSION="v${NEXT_BUILD_VERSION}"
    NEXT_RELEASE_TAG="${PKG_NAME}-${NEXT_RELEASE_VERSION}"
    CURRENT_RELEASE_TAG="${PKG_NAME}-v${CURRENT_BUILD_VERSION}"
  else
    NEXT_RELEASE_VERSION="v${NEXT_BUILD_VERSION}"
    NEXT_RELEASE_TAG="${NEXT_RELEASE_VERSION}"
    CURRENT_RELEASE_TAG="v${CURRENT_BUILD_VERSION}"
  fi

  if [[ -n "${GIT_LAST_PROJECT_TAG_VER}" ]]; then
    RELEASE_DIFF_URL="https://github.com/${GIT_REPO_NAME}/compare/${CURRENT_RELEASE_TAG}...${NEXT_RELEASE_TAG}"
    RELEASE_BODY_TITLE="[${NEXT_RELEASE_TAG}](${RELEASE_DIFF_URL}) (${CURRENT_DATE})"
  else
    RELEASE_BODY_TITLE="${NEXT_RELEASE_TAG} (${CURRENT_DATE})"
  fi

  RELEASE_BODY="# ${RELEASE_BODY_TITLE}\n${RELEASE_BODY}"
}

##############################
######## Handle push ########
##############################

handle_pushes() {
  log_verbose "Applying changes..."
  log_verbose "Found tag commit [${CHECKOUT_SHA}]"

  for plugin in "${PLUGINS[@]}"; do
    log_verbose "Loading plugin \`${plugin}\`..."
    local SOURCE_PLUGIN_FILE="${SCRIPT_DIR}/plugins/${plugin}.sh"
    # shellcheck disable=SC1090 source=/dev/null
    source "${SOURCE_PLUGIN_FILE}"
    release_command=$(command -v release)
    if [[ -n "${release_command}" ]]; then
      release
    fi
    unset release
    log_verbose "Applied plugin ${plugin}!"
  done

  log_verbose "Applied changes!"
}

##############################
######### Initialize #########
##############################
parse_packages
get_git_variables
get_git_commits
handle_git_commits
handle_pushes
