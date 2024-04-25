#!/usr/bin/env bash
set -eu

prepare() {
  if [ "$(command -v GIT_PREPARE)" ]; then
    GIT_PREPARE
  fi
}

cleanup() {
  if [ "$(command -v GIT_CLEANUP)" ]; then
    GIT_CLEANUP
  fi
}

release() {
  # Commiting a `npm` tag
  log "Commiting npm tag..."
  log_verbose "Git hash: $CHECKOUT_SHA!"

  if ! $IS_DRY_RUN; then
    prepare

    git add package.json

    if $IS_WORKSPACE; then
      git commit -m "Bump project ${PKG_NAME} version to ${NEXT_RELEASE_VERSION}"
    else
      git commit -m "Bump package.json version to ${NEXT_RELEASE_VERSION}"
    fi

    if [[ -n "$GIT_REMOTE_ORIGIN" ]]; then
      git push
      log_verbose "Pushed update to remote"
    else
      log_verbose "No Git remote to push tag"
    fi

    cleanup
  else
    log "Skipped commiting npm [$NEXT_RELEASE_TAG] tag in DRY-RUN mode."
  fi
}
