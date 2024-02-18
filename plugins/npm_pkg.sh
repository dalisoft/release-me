#!/usr/bin/env bash
set -e

release() {
  log "Updating package.json version..."
  log_verbose "New version: $RELEASE_VERSION!"

  if ! $IS_DRY_RUN; then
    node -e "
      const fs = require('fs/promises');
      const pkg = require('./package.json');

      fs.writeFile('./package.json', JSON.stringify({
        ...pkg,
        version: '$RELEASE_VERSION'.substr(1)
      }, null, 2))
      "

    echo "Updated package.json version!"
  else
    log "Skipped package.json version udate [$RELEASE_TAG_NAME] in DRY-RUN mode."
  fi
}
