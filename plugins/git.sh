#!/usr/bin/env bash
set -eu

# Global variables
export GPG_TTY=$(tty)

prepare() {
  if [[ -n "${GIT_USERNAME-}" && -n "${GIT_EMAIL-}" ]]; then
    git config --local user.email "$GIT_EMAIL"
    git config --local user.name "$GIT_USERNAME"
    log_verbose "Git username [$GIT_USERNAME] and Git e-mail [$GIT_EMAIL] set"
  fi
  if [[ -n "${GPG_KEY-}" ]]; then
    echo "$GPG_KEY" | base64 --decode | gpg --batch --import
  fi
  if [[ -n "${GPG_KEY_ID-}" ]]; then
    git config --local commit.gpgsign true
    git config --local user.signingkey "$GPG_KEY_ID"
    git config --local tag.forceSignAnnotated true
    git config --local gpg.program gpg
    log_verbose "Git GPG sign and key ID [$GPG_KEY_ID] are set"
  fi
  if [[ -n "${CI-}" && -n "${GPG_PASSPHRASE-}" ]]; then
    echo "allow-loopback-pinentry" >>~/.gnupg/gpg-agent.conf
    echo "pinentry-mode loopback" >>~/.gnupg/gpg.conf
    gpg-connect-agent reloadagent /bye

    gpg --quiet --passphrase "$GPG_PASSPHRASE" --batch --pinentry-mode loopback --sign >/dev/null
    log_verbose "Git GPG passphrase set"
  fi
}

cleanup() {
  if [[ -n "${GIT_USERNAME-}" && -n "${GIT_EMAIL-}" ]]; then
    git config --local --unset user.email
    git config --local --unset user.name
    log_verbose "Git username and Git e-mail unset"
  fi
  if [[ -n "${GPG_KEY_ID-}" ]]; then
    git config --local --unset commit.gpgsign
    git config --local --unset user.signingkey
    git config --local --unset tag.forceSignAnnotated
    git config --local --unset gpg.program
    log_verbose "Git GPG sign unset"
  fi
  if [[ -n "${CI-}" && -n "${GPG_PASSPHRASE-}" ]]; then
    rm -rf ~/.gnupg/gpg-agent.conf
    rm -rf ~/.gnupg/gpg.conf
    log_verbose "Git GPG config cleanup"
  fi

  log_verbose "Git config cleanup"
}

release() {
  # Create a `git` tag
  log "Creating Git tag..."
  log_verbose "Git hash: $CHECKOUT_SHA!"

  if ! $IS_DRY_RUN; then
    prepare

    if [[ -n "${GPG_KEY_ID-}" && -n "${GPG_PASSPHRASE-}" ]]; then
      git tag --sign "$NEXT_RELEASE_TAG" "$CHECKOUT_SHA" --message "Release, tag and sign $NEXT_RELEASE_TAG"
      echo "Created signed Git tag [$NEXT_RELEASE_TAG]!"
    else
      git tag "$NEXT_RELEASE_TAG" "$CHECKOUT_SHA"
      echo "Created Git tag [$NEXT_RELEASE_TAG]!"
    fi

    if [[ -n "$GIT_REMOTE_ORIGIN" ]]; then
      git push origin "refs/tags/$NEXT_RELEASE_TAG"
      log_verbose "Pushed Git tag to remote"
    else
      log_verbose "No Git remote to push tag"
    fi

    cleanup
  else
    log "Skipped Git tag [$NEXT_RELEASE_TAG] in DRY-RUN mode."
  fi
}
