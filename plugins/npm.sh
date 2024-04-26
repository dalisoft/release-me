#!/bin/sh
set -eu

release() {
  # Publish a `npm` tag
  if [ -n "${NPM_TOKEN-}" ]; then
    log "Publishing npm tag..."
    log_verbose "npm tag: $NEXT_RELEASE_TAG and version: $NEXT_RELEASE_VERSION!"

    # Don't load this plugin if
    # - `--dry-run` used
    # - `package.json` is missing
    if ! $IS_DRY_RUN && [ -f package.json ]; then
      TEMP_FILE=$(mktemp)
      printf "%s\n" "//registry.npmjs.org/:_authToken=$NPM_TOKEN" >>"$TEMP_FILE"

      # Bump `package.json` `version` for properly publishing
      sed -i.bak "s/\"version\": \"[^\"]*\",/\"version\": \"$NEXT_BUILD_VERSION\",/" "package.json"
      rm -rf package.json.bak

      export NODE_AUTH_TOKEN="$NPM_TOKEN"
      npm publish --userconfig "$TEMP_FILE"

      log "Published [$NEXT_RELEASE_TAG]!"
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
