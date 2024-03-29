#!/usr/bin/env bash
set -eu

# Global variables
export GPG_TTY=$(tty)
export GNUPGHOME=$(mktemp -d)

prepare() {
  unset GIT_CONFIG

  if [[ -n "${GIT_USERNAME-}" && -n "${GIT_EMAIL-}" ]]; then
    git config --local user.email "$GIT_EMAIL"
    git config --local user.name "$GIT_USERNAME"
    log_verbose "Git username [$GIT_USERNAME] and Git e-mail [$GIT_EMAIL] set"
  fi
  if [[ -z "${GPG_NO_SIGN-}" && -n "${GPG_KEY-}" ]]; then
    echo "$GPG_KEY" | base64 --decode | gpg --homedir "$GNUPGHOME" --quiet --batch --import
  fi
  if [[ -z "${GPG_NO_SIGN-}" && -n "${GPG_KEY_ID-}" ]]; then
    git config --local commit.gpgsign true
    git config --local user.signingkey "$GPG_KEY_ID"
    git config --local tag.forceSignAnnotated true
    git config --local gpg.program gpg
    log_verbose "Git GPG sign and key ID [$GPG_KEY_ID] are set"
  fi

  if [[ -z "${GPG_NO_SIGN-}" && -n "${GPG_PASSPHRASE-}" ]]; then
    echo "allow-loopback-pinentry" >>"$GNUPGHOME/gpg-agent.conf"
    echo "pinentry-mode loopback" >>"$GNUPGHOME/gpg.conf"
    gpg-connect-agent --homedir "$GNUPGHOME" reloadagent /bye

    echo "" | gpg --homedir "$GNUPGHOME" --quiet --passphrase "$GPG_PASSPHRASE" --batch --pinentry-mode loopback --sign >/dev/null
    log_verbose "Git GPG passphrase set"
  fi
}

cleanup() {
  if [[ -n "${GIT_USERNAME-}" && -n "${GIT_EMAIL-}" ]]; then
    git config --local --unset user.email
    git config --local --unset user.name
    log_verbose "Git username and Git e-mail unset"
  fi
  if [[ -z "${GPG_NO_SIGN-}" && -n "${GPG_KEY_ID-}" ]]; then
    git config --local --unset commit.gpgsign
    git config --local --unset user.signingkey
    git config --local --unset tag.forceSignAnnotated
    git config --local --unset gpg.program
    log_verbose "Git GPG sign unset"
  fi
  if [[ -z "${GPG_NO_SIGN-}" && -n "${GPG_KEY_ID-}" && -n "${GPG_PASSPHRASE-}" ]]; then
    gpg --homedir "$GNUPGHOME" --quiet --passphrase "$GPG_PASSPHRASE" --batch --yes --delete-secret-and-public-key "$GPG_KEY_ID"
    log_verbose "Git GPG key deleted"
  fi
  if [[ -z "${GPG_NO_SIGN-}" ]]; then
    rm -rf "$GNUPGHOME/gpg-agent.conf"
    rm -rf "$GNUPGHOME/gpg.conf"
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

    if [[ -z "${GPG_NO_SIGN-}" && -n "${GPG_KEY_ID-}" && -n "${GPG_PASSPHRASE-}" ]]; then
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
