#!/usr/bin/env bash
set -e

release() {
  # Create a `git` tag
  echo "Creating Git tag..."
  if $IS_VERBOSE; then
    echo "Git hash: $CHECKOUT_SHA!"
  fi
  if ! $IS_DRY_RUN; then
    git tag "$RELEASE_TAG_NAME" "$CHECKOUT_SHA"
    git push origin "refs/tags/$RELEASE_TAG_NAME"
    echo "Created Git tag [$RELEASE_TAG_NAME]!"
  else
    echo "Skipped Git tag [$RELEASE_TAG_NAME] in DRY-RUN mode."
  fi
}
