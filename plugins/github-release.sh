#!/usr/bin/env bash
set -eu

release() {
  log_verbose "Release tag: $NEXT_RELEASE_TAG"
  log_verbose "Release title: $RELEASE_BODY_TITLE"
  log_verbose "Release body: \n$RELEASE_BODY"

  # Create a `GitHub` release
  if [[ -n "${GITHUB_TOKEN-}" ]]; then
    log "Creating GitHub release..."
    log_verbose "GitHub release hash: $CHECKOUT_SHA!"

    if ! $IS_DRY_RUN; then
      curl -s -o /dev/null \
        -L \
        -X POST \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer $GITHUB_TOKEN" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "https://api.github.com/repos/$GIT_REPO_NAME/releases" \
        -d "{\"tag_name\":\"$NEXT_RELEASE_TAG\",\"target_commitish\":\"$CHECKOUT_SHA\",\"name\":\"$NEXT_RELEASE_TAG\",\"body\":\"$RELEASE_BODY\",\"draft\":false,\"prerelease\":$PRE_RELEASE_VERSION,\"generate_release_notes\":false,\"make_latest\":\"true\"}"
      log "Created GitHub release [$NEXT_RELEASE_TAG]!"
      log "GitHub release available at https://github.com/$GIT_REPO_NAME/releases/tag/$NEXT_RELEASE_TAG"
    else
      log "Skipped GitHub release [$NEXT_RELEASE_TAG] in DRY-RUN mode."
    fi
  else
    echo "
GitHub Token is not found
Please export GitHub Token so this plugin can be used
"
    exit 1
  fi
}
