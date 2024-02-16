#!/usr/bin/env bash
set -e

function release {
  # To-Do
  rm -rf CHANGELOG.md
  echo -e "$RELEASE_BODY" >>CHANGELOG.md
}
