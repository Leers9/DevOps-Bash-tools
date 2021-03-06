#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-07-03 00:25:24 +0100 (Fri, 03 Jul 2020)
#
#  https://github.com/harisekhon/bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC2034
usage_description="
Uses Spotify API to translate a Spotify public playlist name to ID

Matches the first playlist from your account with a name matching the given argument as a partial string match

If a Spotify playlist ID is given, returns as is

Needed by several other adjacent spotify tools

Caveat: due to limitations of the Spotify API, this only works for public playlists
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="<playlist> [<curl_options>]"

# shellcheck disable=SC1090
. "$srcdir/lib/utils.sh"

help_usage "$@"

min_args 1 "$@"

playlist_name="$1"
shift || :

#if [ "$(uname -s)" = Darwin ]; then
#    awk(){
#        command gawk "$@"
#    }
#fi

# if it's not a playlist id, scan all playlists and take the ID of the first matching playlist name
if [[ "$playlist_name" =~ ^[[:alnum:]]{22}$ ]]; then
    echo "$playlist_name"
else
    # works but could get needlessly complicated to escape all possible regex special chars, switching to partial string match instead
    #playlist_regex="${playlist_id//\//\\/}"
    #playlist_regex="${playlist_regex//\(/\\(}"
    #playlist_regex="${playlist_regex//\)/\\)}"
                   #awk "BEGIN{IGNORECASE=1} /${playlist_regex//\//\\/}/ {print \$1; exit}" || :)"
    playlist_id="$(SPOTIFY_PLAYLISTS_ALL=1 "$srcdir/spotify_playlists.sh" "$@" |
                   grep -Fi -m1 "$playlist_name" |
                   awk '{print $1}' || :)"
    if [ -z "$playlist_id" ]; then
        echo "Error: failed to find playlist ID matching given playlist name '$playlist_name'" >&2
        exit 1
    fi
    echo "$playlist_id"
fi
