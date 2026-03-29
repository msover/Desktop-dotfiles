pid="$(hyprctl activewindow -j | jq -r '.pid')"
cwd="$(readlink -f "/proc/$pid/cwd" 2>/dev/null || echo "$HOME")"

kitty --working-directory "$cwd"
