#!/usr/bin/env bash
set -e

TMP_GIT_CONFIG_FILE=$(mktemp)

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
    echo 'ALLOW_LOOPBACK_PINENTRY=yes' >>~/.gnupg/gpg-agent.conf
    gpg-connect-agent reloadagent /bye
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
      echo "$GPG_KEY_PASSPHRASE" | git tag --sign "$RELEASE_TAG_NAME" --local-user "$GPG_KEY_ID" "$CHECKOUT_SHA" --message "$RELEASE_BODY" --batch --pinentry-mode loopback --passphrase-fd 0
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
