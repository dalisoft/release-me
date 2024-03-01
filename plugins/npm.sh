#!/usr/bin/env bash
set -eu

release() {
  # Publish a `npm` tag
  if [[ "${NPM_TOKEN-}" != "" ]]; then
    log "Publishing npm tag..."
    log_verbose "npm tag: $NEXT_RELEASE_TAG and version: $NEXT_RELEASE_VERSION!"

    if ! $IS_DRY_RUN; then
      TEMP_FILE=$(mktemp)
      echo "//registry.npmjs.org/:_authToken=$NPM_TOKEN" >>"$TEMP_FILE"

      # Bump `package.json` `version` for properly publishing
      if [[ "$(uname)" == "Darwin" ]]; then
        # BSD sed
        sed -i '' "s/\"version\": \"[^\"]*\",/\"version\": \"$NEXT_BUILD_VERSION\",/" "package.json"
      elif [[ "$(uname)" == "Linux" ]]; then
        # GNU sed
        sed -i "s/\"version\": \"[^\"]*\",/\"version\": \"$NEXT_BUILD_VERSION\",/" "package.json"
      fi

      export NODE_AUTH_TOKEN="$NPM_TOKEN"
      npm publish "$NEXT_RELEASE_VERSION" --userconfig "$TEMP_FILE"

      echo "Published [$NEXT_RELEASE_TAG]!"
      rm -rf "$TEMP_FILE"
    else
      log "Skipped npm tag [$NEXT_RELEASE_TAG] in DRY-RUN mode."
    fi
  else
    echo "
npm Token is not found
Please export npm Token so this plugin can be used
"
    exit 1
  fi
}
