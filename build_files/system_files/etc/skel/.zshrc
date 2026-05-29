# Kumori — default zsh config (seeded from /etc/skel).
# Edit freely; this exists mainly so a new account doesn't drop into the
# zsh-newuser-install prompt and has reasonable defaults.

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt inc_append_history share_history hist_ignore_all_dups hist_reduce_blanks

# Behavior
setopt auto_cd interactive_comments no_beep

# Completion
autoload -Uz compinit && compinit -u
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Prompt: prefer starship if present (Bluefin ships it), else a quiet fallback.
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
else
  PROMPT='%F{6}%~%f %# '
fi
