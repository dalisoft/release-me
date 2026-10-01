#!/usr/bin/env bash
set -eu

ROOT_DIR="$(realpath ../..)"

# Keeps the docs site consistent with the project: every CLI option
# is documented, every plugin has a docs page, and the site version
# (package.json, shown in the navbar) never advertises an unreleased
# version.

test_docs_cover_every_cli_option() {
  local missing=""

  local opt name
  while read -r opt; do
    name="${opt%%=*}"
    name="${name#--}"
    if ! grep -qF "\`${name}\`" "${ROOT_DIR}/docs/USAGE.md"; then
      missing="${missing} ${name}"
    fi
  done < <(sed -n '/^Options:$/,/^"$/p' "${ROOT_DIR}/release.sh" | grep -oE -- '--[a-z-]+' | sort -u)

  assert_equals "ok" "$([[ -z "${missing}" ]] && printf ok || printf 'undocumented:%s' "${missing}")"
}

test_docs_cover_every_plugin() {
  local missing=""

  local plugin page
  while read -r plugin; do
    page="${ROOT_DIR}/docs/plugins/$(printf "%s" "${plugin}" | tr '[:lower:]-' '[:upper:]_').md"
    if [[ ! -f "${page}" ]]; then
      missing="${missing} ${plugin}"
    fi
  done < <(cd "${ROOT_DIR}/plugins" && find . -name '*.sh' -maxdepth 1 | sed 's|^\./||; s/\.sh$//' | grep -v '^plugin-template$')

  assert_equals "ok" "$([[ -z "${missing}" ]] && printf ok || printf 'undocumented:%s' "${missing}")"
}

test_docs_version_not_newer_than_latest_release() {
  local pkg latest
  pkg=$(sed -n 's/.*"version": "\([^"]*\)".*/\1/p' "${ROOT_DIR}/package.json" | head -1)
  latest=$(git ls-remote "$(git -C "${ROOT_DIR}" remote get-url origin | sed 's|git@github.com:|https://github.com/|')" "refs/tags/v*" 2>/dev/null |
    sed 's|.*refs/tags/||' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -1)
  latest="${latest#v}"

  # no tags reachable (e.g. offline) - nothing to compare against
  if [[ -z "${latest}" ]]; then
    return 0
  fi

  local pkg_parts latest_parts newer=false
  IFS='.' read -r -a pkg_parts <<<"${pkg}"
  IFS='.' read -r -a latest_parts <<<"${latest}"
  if [[ "${pkg_parts[0]}" -gt "${latest_parts[0]}" ]] ||
    { [[ "${pkg_parts[0]}" -eq "${latest_parts[0]}" ]] && [[ "${pkg_parts[1]}" -gt "${latest_parts[1]}" ]]; } ||
    { [[ "${pkg_parts[0]}" -eq "${latest_parts[0]}" ]] && [[ "${pkg_parts[1]}" -eq "${latest_parts[1]}" ]] && [[ "${pkg_parts[2]}" -gt "${latest_parts[2]}" ]]; }; then
    newer=true
  fi

  assert_equals "ok" "$([[ "${newer}" == false ]] && printf ok || printf 'newer: package.json %s > released %s' "${pkg}" "${latest}")"
}
