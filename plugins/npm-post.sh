#!/bin/sh
set -eu

prepare() {
  unset GIT_CONFIG

  if [ -n "${GIT_USERNAME-}" ] && [ -n "${GIT_EMAIL-}" ]; then
    git config --local user.email "$GIT_EMAIL"
    git config --local user.name "$GIT_USERNAME"
    log_verbose "Git username [$GIT_USERNAME] and Git e-mail [$GIT_EMAIL] set"
  fi

  if [ -z "${GPG_NO_SIGN-}" ] && [ -n "${GPG_KEY-}" ] && [ -n "${GPG_KEY_ID-}" ]; then
    git config --local commit.gpgsign true
    git config --local user.signingkey "$GPG_KEY_ID"
    git config --local tag.forceSignAnnotated true
    git config --local gpg.program gpg
    log_verbose "Git GPG sign and key ID [$GPG_KEY_ID] are set"

    if ! gpg --list-keys | grep -q "${GPG_KEY_ID-}"; then
      echo "$GPG_KEY" | base64 --decode | gpg --quiet --batch --import
      log_verbose "Git GPG key import loaded"
    else
      log_verbose "Git GPG key import skipped"
    fi

    if [ -n "${GPG_PASSPHRASE-}" ]; then
      echo "$GPG_PASSPHRASE" | gpg --quiet --batch --yes --pinentry-mode loopback --sign --local-user "${GPG_KEY_ID-}" --passphrase-fd 0 >/dev/null
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

  if [ -z "${GPG_NO_SIGN-}" ] && [ -n "${GPG_KEY-}" ] && [ -n "${GPG_KEY_ID-}" ]; then
    git config --local --unset commit.gpgsign
    git config --local --unset user.signingkey
    git config --local --unset tag.forceSignAnnotated
    git config --local --unset gpg.program
    log_verbose "Git GPG sign and key ID [$GPG_KEY_ID] are unset"

    if gpg --list-keys | grep -q "${GPG_KEY_ID-}"; then
      if [ -n "${GPG_PASSPHRASE-}" ]; then
        echo "$GPG_PASSPHRASE" | gpg --quiet --batch --yes --passphrase-fd 0 --delete-secret-and-public-key "$GPG_KEY_ID" >/dev/null
      else
        gpg --quiet --batch --yes --delete-secret-and-public-key "$GPG_KEY_ID"
      fi
      log_verbose "Git GPG key deleted"
    fi

    log_verbose "Git GPG config cleanup"
  fi

  log_verbose "Git config cleanup"
}

release() {
  # Committing a `npm` tag
  log "Committing npm tag..."
  log_verbose "Git hash: $CHECKOUT_SHA!"
  if [ -n "${NPM_TOKEN-}" ]; then

    # Don't load this plugin if
    # - `--dry-run` used
    # - `package.json` is missing
    # - `package.json` is not changed on `Git` tracking
    if ! $IS_DRY_RUN; then
      if [ ! -f package.json ] || [ -z "$(git diff --name-only package.json 2>/dev/null)" ]; then
        log "Project does not have package.json or package.json not changed"
        return 1
      fi
      prepare
      git add package.json

      if $IS_WORKSPACE; then
        if [ -z "${GPG_NO_SIGN-}" ] && [ -n "${GPG_KEY-}" ] && [ -n "${GPG_KEY_ID-}" ]; then
          git commit --sign -m "chore(${PKG_NAME}): update \`package.json\` version to ${NEXT_RELEASE_VERSION}"
        else
          git commit --no-gpg-sign -m "chore(${PKG_NAME}): update \`package.json\` version to ${NEXT_RELEASE_VERSION}"
        fi
      else
        if [ -z "${GPG_NO_SIGN-}" ] && [ -n "${GPG_KEY-}" ] && [ -n "${GPG_KEY_ID-}" ]; then
          git commit --sign -m "chore: update \`package.json\` version to ${NEXT_RELEASE_VERSION}"
        else
          git commit --no-gpg-sign -m "chore: update \`package.json\` version to ${NEXT_RELEASE_VERSION}"
        fi
      fi

      if [ -n "$GIT_REMOTE_ORIGIN" ]; then
        git push
        CHECKOUT_SHA=$(git rev-parse HEAD)
        log "Committed npm [$NEXT_RELEASE_TAG] tag"
      else
        log "Committing npm [$NEXT_RELEASE_TAG] tag failed"
      fi

      cleanup
    else
      log "Skipped committing npm [$NEXT_RELEASE_TAG] tag in DRY-RUN mode."
    fi
  else
    echo "
npm Token is not found
Please export npm Token so this plugin can be used
"
    exit 1
  fi
}
