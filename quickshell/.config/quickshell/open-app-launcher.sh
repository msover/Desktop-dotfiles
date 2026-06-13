#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
config_file="$(readlink -f "$script_dir/shell.qml")"

instance_id="$(
    quickshell list --all | awk -v config="$config_file" '
        /^Instance / {
            id = $2
            sub(/:$/, "", id)
        }
        /^  Config path: / {
            path = $0
            sub(/^  Config path: /, "", path)
            cmd = "readlink -f " path
            cmd | getline resolved
            close(cmd)
            if (resolved == config) {
                match_id = id
            }
        }
        END {
            if (match_id != "") {
                print match_id
            }
        }
    '
)"

if [[ -z "$instance_id" ]]; then
    printf 'No running Quickshell instance found for %s\n' "$config_file" >&2
    exit 1
fi

active_monitor="$(hyprctl activeworkspace -j | jq -r '.monitor')"

exec quickshell ipc -i "$instance_id" call app-launcher open "$active_monitor"
