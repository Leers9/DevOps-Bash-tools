#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-07-02 19:11:12 +0100 (Thu, 02 Jul 2020)
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
One-touch Spotify Backup of all or selected Spotify playlists
using code from Spotify Tools and DevOps Bash Tools repos

Without args, also backs up the entire list of public Spotify playlists

\$SPOTIFY_USER must be set in the environment
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="[<playlist> <playlist2> ...]"

# shellcheck disable=SC1090
. "$srcdir/lib/utils.sh"

help_usage "$@"

if [ -z "${SPOTIFY_BACKUP_DIR:-}" ]; then
    if [[ "$PWD" =~ playlists ]]; then
        export SPOTIFY_BACKUP_DIR="$PWD"
    fi
fi

section "Running Spotify Playlists Backup"

if [ $# -gt 0 ]; then
    echo "Backing up selected playlist(s):"
    echo
    for playlist in "$@"; do
        "$srcdir/spotify_backup_playlist.sh" "$playlist"
    done
    exit 0
fi

timestamp "Dumping list of Spotify playlists to spotify/playlists.txt"
"$srcdir/spotify_playlists.sh" "$SPOTIFY_USER" > spotify/playlists.txt
echo >&2

timestamp "Stripping spotify playlist IDs from spotify/playlists.txt => playlists.txt"
sed 's/^[^[:space:]]*[[:space:]]*//' spotify/playlists.txt > playlists.txt
echo >&2

"$srcdir/spotify_backup_playlists.sh"
