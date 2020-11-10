#!/usr/bin/env bash
wd() {
  local -r config_path="${XDG_DATA_HOME:-$HOME/.config}"
  local -r pins="${WD_PINS:-${config_path}/wd/pins.txt}"

  case "$1" in
    --help|-h)
      cat <<USAGE
usage: wd [dir|pin] - Navigates to a directory or pin.

OPTIONS:
  wd --pin   |-p [dir=PWD] [as=PWD basename] - Pins a directory against the given alias.
  wd --unpin |-u [pin=PWD basename]          - Unpins a directory matching the given alias.
  wd --create|-c <dir> [pin]                 - Navigates to a directory, creating it if necessary.
                                               If pin is specified, the directory is also pinned.
  wd --list  |-l                             - Lists all pinned directories.
  wd --help  |-h                             - Displays this message.
USAGE
      ;;
    --list|-l)
      [[ -f "${pins}" ]] || { echo 'No directories pinned' && return; }

      column -s "=" -t < "${pins}"
      ;;
    --pin|-p)
      [[ -f "${pins}" ]] \
        || (mkdir -p "$(dirname "${pins}")" && : > "${pins}") \
        || return 1

      local dir="${2:-${PWD}}"
      # Check directory and expand potential relative paths.
      dir="$(cd "${dir}" >/dev/null && pwd)" || return 1
      local -r name="${3:-${dir##*/}}"

      wd --unpin "${name}" \
        && echo "${name}=${dir}" >> "${pins}" \
        && echo "Pinned ${dir} as '${name}'"
      ;;
    --unpin|-u)
      [[ -f "${pins}" ]] || return 1

      local -r name="${2:-${PWD##*/}}"
      # Read file in subshell before truncating it (see ShellCheck SC2094).
      # shellcheck disable=SC2005
      echo "$(grep -v "^${name//./\\.}=" "${pins}")" > "${pins}"
      ;;
    --create|-c)
      [[ -n "$2" ]] || { wd --help && return 1; }

      local -r dir="$2" pin="$3"
      mkdir -p "${dir}" && wd "${dir}"
      [[ -z "${pin}" ]] || wd --pin . "${pin}"
      ;;
    *)
      local dir="$1"
      [[ -n "${dir}" ]] && [[ -f "${pins}" ]] && {
	local pin; pin="$(grep "^${dir//./\\.}=" "${pins}")" \
  	  && [[ -n "${pin}" ]] \
	  && dir="${pin#*=}" 
      }

      # Quoting this prevents empty `cd` to home directory (ie. runs `cd ""`).
      # shellcheck disable=SC2086
      cd ${dir} >/dev/null && pwd
      ;;
  esac
}
