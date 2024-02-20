#!/usr/bin/env bash
set -e

release() {
  # Publish a `npm` tag
  if [[ "$NPM_TOKEN" != "" ]]; then
    log "Publishing npm tag..."
    log_verbose "npm tag: $RELEASE_TAG_NAME and version: $RELEASE_VERSION!"

    if ! $IS_DRY_RUN; then
      TEMP_FILE=$(mktemp)
      echo "//registry.npmjs.org/:_authToken=$NPM_TOKEN" >>"$TEMP_FILE"

      # Bump `package.json` `version` for properly publishing
      sed -i '' "s/\"version\": \"[^\"]*\",/\"version\": \"$BUILD_VERSION\",/" package.json

      export NODE_AUTH_TOKEN="$NPM_TOKEN"
      npm publish "$RELEASE_VERSION" --userconfig "$TEMP_FILE"

      echo "Published [$RELEASE_TAG_NAME]!"
      rm -rf "$TEMP_FILE"
    else
      log "Skipped npm tag [$RELEASE_TAG_NAME] in DRY-RUN mode."
    fi
  else
    echo "
npm Token is not found
Please export npm Token so this plugin can be used
"
  fi
}
