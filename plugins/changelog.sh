#!/bin/sh
set -eu

release() {
  log_verbose "CHANGELOG version: ${NEXT_RELEASE_TAG-}"
  log_verbose "CHANGELOG content: \n${RELEASE_BODY-}"

  log "Generating Changelog..."
  if ! ${IS_DRY_RUN-}; then
    CONTENT=""
    if [ -f CHANGELOG.md ]; then
      CONTENT="\n$(cat CHANGELOG.md)"
    fi
    rm -rf CHANGELOG.md
    printf "%b%b" "${RELEASE_BODY}" "${CONTENT}" >>CHANGELOG.md
    log "Generated Changelog!"
  else
    log "Skipped Changelog creation in DRY-RUN mode..."
  fi
}
