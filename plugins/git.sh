#!/usr/bin/env bash
set -e

TEMP_GPG_FILE=$(mktemp)

prepare() {
  if [[ -n "$GIT_USERNAME" && -n "$GIT_EMAIL" ]]; then
    git config --global user.email "$GIT_EMAIL"
    git config --global user.name "$GIT_USERNAME"
  fi
  if [[ -n "$GPG_KEY_ID" ]]; then
    git config --global commit.gpgsign true
    git config --global user.signingkey "$GPG_KEY_ID"
  fi
  if [[ -n "$GPG_KEY_ID" && -n "$GPG_KEY" && -n "$GPG_PASSPHARE" ]]; then
    echo "$GPG_KEY" | base64 --decode | gpg --batch --import
    rm -rf "$TEMP_GPG_FILE"
    echo '#!/bin/bash' >>"$TEMP_GPG_FILE"
    echo "gpg --batch --pinentry-mode=loopback --passphrase $GPG_KEY_PASSPHRASE " >>"$TEMP_GPG_FILE"
    chmod +x "$TEMP_GPG_FILE"
    git config --global gpg.program "$TEMP_GPG_FILE"
  fi
}

cleanup() {
  if [[ -n "$GIT_USERNAME" && -n "$GIT_EMAIL" ]]; then
    git config --global --unset user.email
    git config --global --unset user.name
  fi
  if [[ -n "$GPG_KEY_ID" ]]; then
    git config --global --unset commit.gpgsign true
    git config --global --unset user.signingkey "$GPG_KEY_ID"
  fi
  if [[ -n "$GPG_KEY_ID" && -n "$GPG_KEY" && -n "$GPG_PASSPHARE" ]]; then
    rm -rf "$TEMP_GPG_FILE"
    git config --global --unset gpg.program
  fi

  git config --global --unset credential.helper
}

release() {
  # Create a `git` tag
  log "Creating Git tag..."
  log_verbose "Git hash: $CHECKOUT_SHA!"

  if ! $IS_DRY_RUN; then
    prepare

    if [[ -n "$GPG_KEY_ID" ]]; then
      git tag --sign "$RELEASE_TAG_NAME" "$CHECKOUT_SHA"
    else
      git tag "$RELEASE_TAG_NAME" "$CHECKOUT_SHA"
    fi
    git push origin "refs/tags/$RELEASE_TAG_NAME"
    echo "Created Git tag [$RELEASE_TAG_NAME]!"

    cleanup
  else
    log "Skipped Git tag [$RELEASE_TAG_NAME] in DRY-RUN mode."
  fi
}
