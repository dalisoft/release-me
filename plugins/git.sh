#!/usr/bin/env bash
set -e

release() {
  # Create a `git` tag
  log "Creating Git tag..."
  log_verbose "Git hash: $CHECKOUT_SHA!"

  if ! $IS_DRY_RUN; then
    git tag "$RELEASE_TAG_NAME" "$CHECKOUT_SHA"
    git push origin "refs/tags/$RELEASE_TAG_NAME"
    echo "Created Git tag [$RELEASE_TAG_NAME]!"
  else
    log "Skipped Git tag [$RELEASE_TAG_NAME] in DRY-RUN mode."
  fi
}
