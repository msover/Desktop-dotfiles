#
# ~/.bashrc
#

# If not running interactively, don't do anything

export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"

[[ $- != *i* ]] && return

alias grep='grep --color=auto'
alias pwoff='poweroff'
alias ripdrag='ripdrag -Axi'

eval "$(starship init bash)"
eval "$(zoxide init bash)"
# aliases that give omarchy looknfeel
alias ls='eza -lha --group-directories-first --icons=auto'
alias cat='bat --paging=never'

bind -s 'set completion-ignore-case on'

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
