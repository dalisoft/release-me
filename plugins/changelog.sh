#!/usr/bin/env bash
set -e

release() {
  echo "Generating Changelog..."
  if ! $IS_DRY_RUN; then
    local CONTENT=""
    if [ -f CHANGELOG.md ]; then
      CONTENT=$(cat CHANGELOG.md)
    fi
    rm -rf CHANGELOG.md
    echo -e "$RELEASE_BODY\n$CONTENT" >>CHANGELOG.md
    echo "Generated Changelog!"
  else
    echo "Skipped Changelog creation in DRY-RUN mode..."
  fi
}
