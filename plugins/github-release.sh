#!/usr/bin/env bash
set -e

release() {
  # Create a `GitHub` release
  if [[ "$GITHUB_TOKEN" != "" ]]; then
    echo "Creating GitHub release..."
    echo "GitHub release hash: $CHECKOUT_SHA!"
    if ! $IS_DRY_RUN; then
      curl -s -o /dev/null \
        -L \
        -X POST \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer $GITHUB_TOKEN" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "https://api.github.com/repos/$GIT_REPO_NAME/releases" \
        -d "{\"tag_name\":\"$RELEASE_TAG_NAME\",\"target_commitish\":\"$CHECKOUT_SHA\",\"name\":\"$RELEASE_TAG_NAME\",\"body\":\"$RELEASE_BODY\",\"draft\":false,\"prerelease\":false,\"generate_release_notes\":false,\"make_latest\":\"true\"}"
      echo "Created GitHub release [$RELEASE_TAG_NAME]!"
      echo "GitHub release available at https://github.com/$GIT_REPO_NAME/releases/tag/$RELEASE_TAG_NAME"
    else
      echo "Skipped GitHub release [$RELEASE_TAG_NAME] in DRY-RUN mode."
    fi
  else
    echo "
GitHub Token is not found
Please export GitHub Token so this plugin can be used
"
  fi
}
