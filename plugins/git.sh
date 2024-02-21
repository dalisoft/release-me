#!/usr/bin/env bash
set -e

export GPG_TTY=$(tty)
export GIT_CONFIG=$(mktemp)

prepare() {
  if [[ -n "$GIT_USERNAME" && -n "$GIT_EMAIL" ]]; then
    git config user.email "$GIT_EMAIL"
    git config user.name "$GIT_USERNAME"
    log_verbose "Git username [$GIT_USERNAME] and Git e-mail [$GIT_EMAIL] set"
  fi
  if [[ -n "$GPG_KEY" ]]; then
    echo "$GPG_KEY" | base64 --decode | gpg --batch --import
  fi
  if [[ -n "$GPG_KEY_ID" ]]; then
    git config commit.gpgsign true
    git config user.signingkey "$GPG_KEY_ID"
    git config tag.forceSignAnnotated true
    git config gpg.program gpg
    log_verbose "Git GPG sign and key ID [$GPG_KEY_ID] are set"
  fi
  if [[ -n "$GPG_PASSPHRASE" ]]; then
    echo "allow-loopback-pinentry" >>~/.gnupg/gpg-agent.conf
    echo "pinentry-mode loopback" >>~/.gnupg/gpg.conf
    gpg-connect-agent reloadagent /bye

    gpg --passphrase "$GPG_PASSPHRASE" --batch --pinentry-mode loopback --sign
    log_verbose "Git GPG passphrase set"
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
    git config --unset gpg.program
    log_verbose "Git GPG sign unset"
  fi
  if [[ -n "$GPG_PASSPHRASE" ]]; then
    rm -rf ~/.gnupg/gpg-agent.conf
    rm -rf ~/.gnupg/gpg.conf
    log_verbose "Git GPG config cleanup"
  fi

  rm -rf "$GIT_CONFIG"
  log_verbose "Git config cleanup"
}

release() {
  # Create a `git` tag
  log "Creating Git tag..."
  log_verbose "Git hash: $CHECKOUT_SHA!"

  if ! $IS_DRY_RUN; then
    prepare

    if [[ -n "$GPG_KEY_ID" && -n "$GPG_PASSPHRASE" ]]; then
      git tag --sign "$RELEASE_TAG_NAME" "$CHECKOUT_SHA" --message "Release, tag and sign $RELEASE_TAG_NAME"
      echo "Created signed Git tag [$RELEASE_TAG_NAME]!"
    else
      git tag "$RELEASE_TAG_NAME" "$CHECKOUT_SHA"
      echo "Created Git tag [$RELEASE_TAG_NAME]!"
    fi

    git push origin "refs/tags/$RELEASE_TAG_NAME"
    log_verbose "Pushed Git tag to remote"

    cleanup
  else
    log "Skipped Git tag [$RELEASE_TAG_NAME] in DRY-RUN mode."
  fi
}
