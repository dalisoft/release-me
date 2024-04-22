#!/bin/sh
set -eu

SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
PRESET=""
PLUGINS=""
OUTDIR="$SCRIPT_DIR/build"

prepare() {
  mkdir -p "$SCRIPT_DIR/build"
}

parse_options() {
  IFS=','

  while :; do
    KEY="${1-}"
    case "$KEY" in
    --plugins=*)
      PLUGINS=$(echo "${KEY#*=}" | tr ',' ' ')
      ;;
    --preset=*)
      PRESET="${KEY#*=}"
      ;;
    --outdir=*)
      OUTDIR="${KEY#*=}"
      ;;
    -?*)
      echo "$CLI_PREFIX Unknown option: $KEY"
      exit 1
      ;;
    ?*)
      echo "$CLI_PREFIX Unknown argument: $KEY"
      exit 1
      ;;
    "")
      break
      ;;
    esac
    shift
  done
}

build_prepare() {
  build_file="$OUTDIR/release.sh"
  rm -rf "$build_file"
  touch "$build_file"
  chmod +x "$build_file"

  echo "#!/bin/bash" >>"$build_file"
  echo "set -euo pipefail" >>"$build_file"

  preset_file="$SCRIPT_DIR/presets/${PRESET}.sh"
  if [ -n "$PRESET" ] && [ -f "$preset_file" ]; then
    cat "$preset_file" | tail -n +3 >>"$build_file"
  fi

  IFS=' '
  for plugin in ${PLUGINS}; do
    plugin_file="$SCRIPT_DIR/plugins/${plugin}.sh"
    if [ -f "$plugin_file" ]; then
      cat "$plugin_file" | tail -n +3 | sed "s/release/plugin_${plugin}_release/g" >>"$build_file"
    fi
  done

  cat "$SCRIPT_DIR/release.sh" | tail -n +3 >>"$build_file"
  sed -E -i.bak "s/PLUGINS\=\"git\"/PLUGINS\=\"${PLUGINS}\"/g" "$build_file"

  rm -rf "$build_file.bak"
}

prepare
parse_options "$@"
build_prepare
