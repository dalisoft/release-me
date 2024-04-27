#!/bin/sh
set -eu

release() {
  log_verbose "Release tag: $NEXT_RELEASE_TAG"
  log_verbose "Release title: $RELEASE_BODY_TITLE"
  log_verbose "Release body: \n$RELEASE_BODY"

  # Create a `GitHub` release
  if [ -n "${GITHUB_TOKEN-}" ]; then
    log "Creating GitHub release..."
    log_verbose "GitHub release hash: $CHECKOUT_SHA!"

    if ! $IS_DRY_RUN; then
      if ! command -v gh; then
        echo "GitHub CLI not found your machine"
        return 1
      fi

      if $PRE_RELEASE_VERSION; then
        printf "%b" "${RELEASE_BODY-}" | gh release create "${NEXT_RELEASE_TAG-}" --title "${NEXT_RELEASE_TAG-}" --prerelease --notes-file -
      else
        printf "%b" "${RELEASE_BODY-}" | gh release create "${NEXT_RELEASE_TAG-}" --title "${NEXT_RELEASE_TAG-}" --latest --notes-file -
      fi
    else
      log "Skipped GitHub release [$NEXT_RELEASE_TAG] in DRY-RUN mode."
    fi
  else
    echo "
GitHub Token is not found
Please export GitHub Token so this plugin can be used
"
    exit 1
  fi
}
