#!/usr/bin/env bash
set -e

release() {
  log "Updating package.json version..."
  log_verbose "New version: $RELEASE_VERSION!"

  if ! $IS_DRY_RUN; then
    sed -i '' "s/\"version\": \"[^\"]*\",/\"version\": \"$BUILD_VERSION\",/" package.json

    echo "Updated package.json version!"
  else
    log "Skipped package.json version update [$RELEASE_TAG_NAME] in DRY-RUN mode."
  fi
}
