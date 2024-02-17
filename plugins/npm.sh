#!/usr/bin/env bash
set -e

release() {
  # Publish a `npm` tag
  log "Publishing npm tag..."
  log_verbose "npm tag: $RELEASE_TAG_NAME!"

  if ! $IS_DRY_RUN; then
    npm publish "$RELEASE_TAG_NAME"
    echo "Published [$RELEASE_TAG_NAME]!"
  else
    log "Skipped npm tag [$RELEASE_TAG_NAME] in DRY-RUN mode."
  fi
}
