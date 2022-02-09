#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

# BEGIN_KITTY_SHELL_INTEGRATION
if test -n "$KITTY_INSTALLATION_DIR" -a -e "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; then source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; fi
# END_KITTY_SHELL_INTEGRATION

sh ./Documentos/fetch

alias bashrc='nvim ~/.bashrc'
alias zshrc='nvim ~/.zshrc'

alias bspwmrc='nvim ~/.config/bspwm/bspwmrc'
alias sxhkdrc='nvim ~/.config/sxhkd/sxhkdrc'
