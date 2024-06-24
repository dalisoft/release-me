#!/bin/sh
set -eu

prepare() {
  unset GIT_CONFIG

  if [ -n "${GIT_USERNAME-}" ] && [ -n "${GIT_EMAIL-}" ]; then
    git config --local user.email "${GIT_EMAIL}"
    git config --local user.name "${GIT_USERNAME}"
    log_verbose "Git username [${GIT_USERNAME}] and Git e-mail [${GIT_EMAIL}] set"
  fi

  if [ -z "${GPG_NO_SIGN-}" ] && [ -n "${GPG_KEY-}" ] && [ -n "${GPG_KEY_ID-}" ]; then
    git config --local commit.gpgsign true
    git config --local user.signingkey "${GPG_KEY_ID}"
    git config --local tag.forceSignAnnotated true
    git config --local gpg.program gpg
    log_verbose "Git GPG sign and key ID [${GPG_KEY_ID}] are set"

    if ! gpg --list-keys | grep -q "${GPG_KEY_ID-}"; then
      printf "%s" "${GPG_KEY}" | base64 --decode | gpg --quiet --batch --import
      log_verbose "Git GPG key import loaded"
    else
      log_verbose "Git GPG key import skipped"
    fi

    if [ -n "${GPG_PASSPHRASE-}" ]; then
      printf "%s" "${GPG_PASSPHRASE}" | gpg --quiet --batch --yes --pinentry-mode loopback --sign --local-user "${GPG_KEY_ID-}" --passphrase-fd 0 >/dev/null
      log_verbose "Git GPG passphrase set"
    fi
  elif [ -z "${SSH_NO_SIGN-}" ] && [ -n "${SSH_PRIVATE_KEY-}" ] && [ -n "${SSH_PUBLIC_KEY-}" ]; then
    SSH_PUBLIC_KEY_FILE=$(mtemp)
    print "%s" "${SSH_PUBLIC_KEY}" >>"${SSH_PUBLIC_KEY_FILE}"

    git config --local commit.gpgsign true
    git config --local user.signingkey "${SSH_PUBLIC_KEY_FILE}"
    git config --local tag.forceSignAnnotated true
    git config --local gpg.format ssh
    log_verbose "Git SSH sign key is set"

    if [ -n "${SSH_KEY_PASSPHRASE-}" ]; then
      SSH_ASKPASS_FILE=$(mktemp)
      chmod 0755 "${SSH_ASKPASS_FILE}"
      print "%s" "echo -n \"${SSH_KEY_PASSPHRASE}\"" >>"${SSH_ASKPASS_FILE}"

      export SSH_ASKPASS="${SSH_ASKPASS_FILE}"
      export SSH_ASKPASS_REQUIRE="force"
      log_verbose "Git SSH passphrase set"
    fi

    if ! ssh-add -L | grep -q "${SSH_PUBLIC_KEY-}"; then
      printf "%s" "${SSH_PRIVATE_KEY}" | base64 --decode | ssh-add -
      log_verbose "Git SSH key import loaded"
    else
      log_verbose "Git SSH key import skipped"
    fi

    rm -rf "${SSH_ASKPASS}"
    unset SSH_ASKPASS
    unset SSH_ASKPASS_REQUIRE
    log_verbose "Git SSH key security cleanup"
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
    log_verbose "Git GPG sign and key ID [${GPG_KEY_ID}] are unset"

    if gpg --list-keys | grep -q "${GPG_KEY_ID-}"; then
      if [ -n "${GPG_PASSPHRASE-}" ]; then
        printf "%s" "${GPG_PASSPHRASE}" | gpg --quiet --batch --yes --passphrase-fd 0 --delete-secret-and-public-key "${GPG_KEY_ID}" >/dev/null
      else
        gpg --quiet --batch --yes --delete-secret-and-public-key "${GPG_KEY_ID}"
      fi
      log_verbose "Git GPG key deleted"
    fi

    log_verbose "Git GPG config cleanup"
  elif [ -z "${SSH_NO_SIGN-}" ] && [ -n "${SSH_PUB_KEY-}" ]; then
    git config --local --unset commit.gpgsign true
    git config --local --unset user.signingkey "${SSH_PUB_KEY}"
    git config --local --unset tag.forceSignAnnotated true
    git config --local --unset gpg.format ssh

    ssh-add -L | grep -F "${SSH_PUBLIC_KEY-}" | ssh-add -d -
    log_verbose "Git SSH sign is unset"
  fi

  log_verbose "Git config cleanup"
}

release() {
  # Create a `git` tag
  log "Creating Git tag..."
  log_verbose "Git hash: ${CHECKOUT_SHA-}!"

  if ! ${IS_DRY_RUN-}; then
    prepare

    if [ -z "${GPG_NO_SIGN-}" ] && [ -n "${GPG_KEY-}" ] && [ -n "${GPG_KEY_ID-}" ]; then
      git tag --sign "${NEXT_RELEASE_TAG-}" "${CHECKOUT_SHA}" --message "Release, tag and sign ${NEXT_RELEASE_TAG}"
      log "Created GPG signed Git tag [${NEXT_RELEASE_TAG}]!"
    elif [ -z "${SSH_NO_SIGN-}" ] && [ -n "${SSH_PUB_KEY-}" ]; then
      git tag --sign "${NEXT_RELEASE_TAG}" "${CHECKOUT_SHA}" --message "Release, tag and sign ${NEXT_RELEASE_TAG}"
      log "Created SSH signed Git tag [${NEXT_RELEASE_TAG}]!"
    else
      git tag "${NEXT_RELEASE_TAG}" "${CHECKOUT_SHA}"
      log "Created Git tag [${NEXT_RELEASE_TAG}]!"
    fi

    if [ -n "${GIT_REMOTE_ORIGIN}" ]; then
      git push origin "refs/tags/${NEXT_RELEASE_TAG}" --no-verify
      log_verbose "Pushed Git tag to remote"
    else
      log_verbose "No Git remote to push tag"
    fi

    cleanup
  else
    log "Skipped Git tag [${NEXT_RELEASE_TAG}] in DRY-RUN mode."
  fi
}
