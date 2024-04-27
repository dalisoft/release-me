#!/bin/sh
set -eu

release() {
  # Build and publish a `Docker` tag
  if [ -n "${DOCKER_HUB_PAT-}" ]; then
    log "Building and publishing Docker image..."
    log_verbose "Docker tag: $NEXT_RELEASE_TAG and version: $NEXT_RELEASE_VERSION!"

    # Don't load this plugin if
    # - `--dry-run` used
    # - `Dockerfile` is missing
    if ! $IS_DRY_RUN; then
      if [ ! -f Dockerfile ]; then
        log "Project does not have Dockerfile"
        return 1
      fi

      docker build . -t "$GIT_REPO_NAME:$NEXT_BUILD_VERSION"
      docker push "$GIT_REPO_NAME:$NEXT_BUILD_VERSION"

      log "Docker image published [$NEXT_RELEASE_TAG]!"
    else
      log "Skipped Docker image [$NEXT_RELEASE_TAG] in DRY-RUN mode."
    fi
  else
    echo "
Docker Personal Access Token is not found
Please export Docker Personal Access Token so this plugin can be used
"
    exit 1
  fi
}