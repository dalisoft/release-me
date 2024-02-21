#!/usr/bin/env bash
set -e

TEMP_GPG_FILE=$(mktemp)
TMP_GIT_CONFIG_FILE=$(mktemp)

export GPG_TTY=$(tty)

prepare() {
  export GIT_CONFIG="$TMP_GIT_CONFIG_FILE"
  if [[ -n "$GIT_USERNAME" && -n "$GIT_EMAIL" ]]; then
    git config user.email "$GIT_EMAIL"
    git config user.name "$GIT_USERNAME"
    log_verbose "Git username and Git e-mail set"
  fi
  if [[ -n "$GPG_KEY" ]]; then
    echo "$GPG_KEY" | base64 --decode | gpg --batch --import
  fi
  if [[ -n "$GPG_KEY_ID" ]]; then
    git config commit.gpgsign true
    git config user.signingkey "$GPG_KEY_ID"
    git config tag.forceSignAnnotated true
    log_verbose "Git GPG sign set"
  fi
  if [[ -n "$GPG_KEY_PASSPHRASE" ]]; then
    rm -rf "$TEMP_GPG_FILE"
    echo '#!/bin/bash' >>"$TEMP_GPG_FILE"
    echo 'gpg --batch --pinentry-mode=loopback --passphrase $GPG_KEY_PASSPHRASE $@' >>"$TEMP_GPG_FILE"
    chmod +x "$TEMP_GPG_FILE"
    git config gpg.program "$TEMP_GPG_FILE"
  fi
}

cleanup() {
  if [[ -n "$GIT_USERNAME" && -n "$GIT_EMAIL" ]]; then
    git config --unset user.email
    git config --unset user.name
    log_verbose "Git username and Git e-mail unset"
  fi
  if [[ -n "$GPG_KEY_ID" ]]; then
    git config --unset commit.gpgsign
    git config --unset user.signingkey
    git config --unset tag.forceSignAnnotated
    log_verbose "Git GPG sign unset"
  fi
  if [[ -n "$GPG_KEY_ID" && -n "$GPG_KEY" && -n "$GPG_KEY_PASSPHRASE" ]]; then
    rm -rf "$TEMP_GPG_FILE"
    git config --unset gpg.program
  fi

  git config --unset credential.helper
  rm -rf "$TMP_GIT_CONFIG_FILE"
}

release() {
  # Create a `git` tag
  log "Creating Git tag..."
  log_verbose "Git hash: $CHECKOUT_SHA!"

  if ! $IS_DRY_RUN; then
    prepare

    if [[ -n "$GPG_KEY_ID" ]]; then
      git tag --sign "$RELEASE_TAG_NAME" --local-user "$GPG_KEY_ID" "$CHECKOUT_SHA" --message "$RELEASE_BODY"
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
