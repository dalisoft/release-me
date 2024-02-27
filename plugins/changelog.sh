#!/usr/bin/env bash
set -e

release() {
  log_verbose "CHANGELOG version: $NEXT_RELEASE_TAG"
  log_verbose "CHANGELOG content: \n$RELEASE_BODY"

  log "Generating Changelog..."
  if ! $IS_DRY_RUN; then
    local CONTENT=""
    if [ -f CHANGELOG.md ]; then
      CONTENT="\n"
      CONTENT+=$(cat CHANGELOG.md)
    fi
    rm -rf CHANGELOG.md
    echo -e "$RELEASE_BODY$CONTENT" >>CHANGELOG.md
    echo "Generated Changelog!"
  else
    log "Skipped Changelog creation in DRY-RUN mode..."
  fi
}
