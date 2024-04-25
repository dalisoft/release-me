#!/bin/sh
set -eu

# Global variables
export GPG_TTY=
export GNUPGHOME=

prepare() {
  unset GIT_CONFIG

  GPG_TTY=$(tty)
  GNUPGHOME=$(mktemp -d)

  if [ -n "${GIT_USERNAME-}" ] && [ -n "${GIT_EMAIL-}" ]; then
    git config --local user.email "$GIT_EMAIL"
    git config --local user.name "$GIT_USERNAME"
    log_verbose "Git username [$GIT_USERNAME] and Git e-mail [$GIT_EMAIL] set"
  fi

  if [ -z "${GPG_NO_SIGN-}" ] && [ -n "${GPG_KEY_ID-}" ]; then
    echo "$GPG_KEY" | base64 --decode | gpg --homedir "$GNUPGHOME" --quiet --batch --import

    git config --local commit.gpgsign true
    git config --local user.signingkey "$GPG_KEY_ID"
    git config --local tag.forceSignAnnotated true
    git config --local gpg.program gpg
    log_verbose "Git GPG sign and key ID [$GPG_KEY_ID] are set"

    echo "allow-loopback-pinentry" >>"$GNUPGHOME/gpg-agent.conf"
    echo "pinentry-mode loopback" >>"$GNUPGHOME/gpg.conf"
    gpg-connect-agent --homedir "$GNUPGHOME" reloadagent /bye

    if [ -n "${GPG_PASSPHRASE}" ]; then
      echo "" | gpg --homedir "$GNUPGHOME" --quiet --passphrase "$GPG_PASSPHRASE" --batch --pinentry-mode loopback --sign >/dev/null
      log_verbose "Git GPG passphrase set"
    fi
  fi
}

cleanup() {
  if [ -n "${GIT_USERNAME-}" ] && [ -n "${GIT_EMAIL-}" ]; then
    git config --local --unset user.email
    git config --local --unset user.name
    log_verbose "Git username and Git e-mail unset"
  fi

  if [ -z "${GPG_NO_SIGN-}" ] && [ -n "${GPG_KEY_ID-}" ]; then
    git config --local --unset commit.gpgsign
    git config --local --unset user.signingkey
    git config --local --unset tag.forceSignAnnotated
    git config --local --unset gpg.program
    log_verbose "Git GPG sign unset"

    if [ -n "${GPG_PASSPHRASE}" ]; then
      gpg --homedir "$GNUPGHOME" --quiet --passphrase "$GPG_PASSPHRASE" --batch --yes --delete-secret-and-public-key "$GPG_KEY_ID"

      log_verbose "Git GPG key deleted"
    fi

    rm -rf "$GNUPGHOME"
    log_verbose "Git GPG config cleanup"
  fi

  log_verbose "Git config cleanup"
}

release() {
  # Commiting a `npm` tag
  log "Committing npm tag..."
  log_verbose "Git hash: $CHECKOUT_SHA!"

  if ! $IS_DRY_RUN; then
    prepare

    git add package.json

    if $IS_WORKSPACE; then
      if [ -z "${GPG_NO_SIGN-}" ] && [ -n "${GPG_KEY_ID-}" ] && [ -n "${GPG_PASSPHRASE-}" ]; then
        git commit --sign -m "Bump project ${PKG_NAME} version to ${NEXT_RELEASE_VERSION}"
      else
        git commit --no-gpg-sign -m "Bump project ${PKG_NAME} version to ${NEXT_RELEASE_VERSION}"
      fi
    else
      if [ -z "${GPG_NO_SIGN-}" ] && [ -n "${GPG_KEY_ID-}" ] && [ -n "${GPG_PASSPHRASE-}" ]; then
        git commit --sign -m "Bump package.json version to ${NEXT_RELEASE_VERSION}"
      else
        git commit --no-gpg-sign -m "Bump package.json version to ${NEXT_RELEASE_VERSION}"
      fi
    fi

    if [ -n "$GIT_REMOTE_ORIGIN" ]; then
      git push
      log_verbose "Pushed update to remote"
    else
      log_verbose "No Git remote to push tag"
    fi

    cleanup
  else
    log "Skipped commiting npm [$NEXT_RELEASE_TAG] tag in DRY-RUN mode."
  fi
}
