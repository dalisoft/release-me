#!/bin/sh
set -eu

release() {
  # Publish a `npm` tag with token or Trusted publishing (OIDC)
  log "Publishing npm tag..."
  log_verbose "npm tag: ${NEXT_RELEASE_TAG-} and version: ${NEXT_RELEASE_VERSION-}!"

  # Don't load this plugin if
  # - `--dry-run` used
  # - `package.json` is missing
  if ! ${IS_DRY_RUN-}; then
    if [ ! -f package.json ]; then
      log "Project does not have package.json"
      return 1
    fi

    if [ -n "${NPM_TOKEN-}" ]; then
      TEMP_FILE=$(mktemp)
      printf "%s\n" "//registry.npmjs.org/:_authToken=${NPM_TOKEN}" >>"${TEMP_FILE}"
      export NODE_AUTH_TOKEN="${NPM_TOKEN}"
    fi

    # Bump `package.json` `version` for properly publishing
    sed -i.bak "s/\"version\": \"[^\"]*\",/\"version\": \"${NEXT_BUILD_VERSION-}\",/" "package.json"
    rm -rf package.json.bak

    # without a token npm >= 11.5.1 exchanges the CI's OIDC token
    # (Trusted publishing) for a short-lived publish token
    if [ -n "${TEMP_FILE-}" ]; then
      npm publish --provenance --userconfig "${TEMP_FILE}"
    else
      npm publish --provenance
    fi

    log "Published [${NEXT_RELEASE_TAG}]!"

    if [ -n "${TEMP_FILE-}" ]; then
      rm -rf "${TEMP_FILE}"
    fi
  else
    log "Skipped npm tag [${NEXT_RELEASE_TAG}] in DRY-RUN mode."
  fi
}
