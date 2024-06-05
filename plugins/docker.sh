#!/bin/sh
set -eu

# Docker buildx script was copied from
# https://docs.docker.com/build/cloud/ci
# and modified by @dalisoft for AMD64/ARM64 platforms

# TODO: This `node` trick for bypassing coverage bug in Bashcov
# See https://github.com/infertux/bashcov/issues/86
ARCH=$(node -p "process.arch.replace('aarch64', 'arm64').replace(/x86_64|x64/, 'amd64')")
OS=$(uname -s | tr '[:upper:]' '[:lower:]')

prepare() {
  BUILDX_URL=$(curl -s https://raw.githubusercontent.com/docker/actions-toolkit/main/.github/buildx-lab-releases.json | grep "${OS}-${ARCH}\",$" | head -1 | xargs | tr -d ',' | xargs)
  # Download docker buildx with Hyrdobuild support
  mkdir -vp ~/.docker/cli-plugins/
  curl --silent -L --output ~/.docker/cli-plugins/docker-buildx "${BUILDX_URL}"
  chmod a+x ~/.docker/cli-plugins/docker-buildx

  echo "${DOCKER_HUB_PAT-}" | docker login --username "${DOCKER_HUB_USERNAME-}" --password-stdin
}

cleanup() {
  rm -rf ~/.docker/cli-plugins/

  docker logout
}

release() {
  # Build and publish a `Docker` tag
  if [ -n "${DOCKER_HUB_USERNAME-}" ] && [ -n "${DOCKER_HUB_PAT-}" ]; then

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

      prepare

      docker build -t "$GIT_REPO_NAME:$NEXT_BUILD_VERSION" . --push
      docker tag "$GIT_REPO_NAME:$NEXT_BUILD_VERSION" "$GIT_REPO_NAME:latest"
      docker push "$GIT_REPO_NAME:latest"

      log "Docker image published [$NEXT_RELEASE_TAG]!"

      cleanup
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
