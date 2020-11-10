# wd

A tiny Bash function that wraps `cd`, to provide commands for directory:
- Pinning (bookmarking)
- Creation (basically `mkdir -p x && cd x (&& pin x)`)

## Installation

### Curl

Download the script and source it in your `.bash_profile`.

Example:
```bash
(cd && curl -OJ https://raw.githubusercontent.com/seifkamal/wd/main/wd.sh)
echo "source wd.sh" >> ~/.bash_profile
```

## Usage

```bash
$ wd --help
usage: wd [dir|pin] - Navigates to a directory or pin.

OPTIONS:
  wd --pin   |-p [dir=PWD] [as=PWD basename] - Pins a directory against the given alias.
  wd --unpin |-u [pin=PWD basename]          - Unpins a directory matching the given alias.
  wd --create|-c <dir> [pin]                 - Navigates to a directory, creating it if necessary.
                                               If pin is specified, the directory is also pinned.
  wd --list  |-l                             - Lists all pinned directories.
  wd --help  |-h                             - Displays this message.
```

A pin-directory map is stored in a `pins.txt` file in your `XDF_DATA_HOME`
directory (ie. `~/.config/wd`). This can be changed by passing a different
value for the `pins` variable (eg. `WD_PINS=my/pins.txt wd -l`). If you
do so, you may wish to alias this in your `.bash_profile` for convenience
(eg. `alias wd="WD_PINS=pins.txt wd"`).

**Note:** `cd` flags (ie. `-L` and `-P`) are currently not supported.
