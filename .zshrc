#------------------------------------------------------------------#
# File:     .zshrc   ZSH resource file                             #
# Version:  0.1.16                                                 #
# Author:   Øyvind "Mr.Elendig" Heggstad <mrelendig@har-ikkje.net> #
#------------------------------------------------------------------#

#------------------------------
# History stuff
#------------------------------
current_prompt=""

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

export GOPATH=~/dev/go
export PATH=GOPATH/bin:$PATH

#setopt correctall

#------------------------------
# Variables
#------------------------------
export EDITOR="vim"
export PAGER="less"
export OOO_FORCE_DESKTOP="gnome"
export PATH="${PATH}:${HOME}/bin:${HOME}/.cabal/bin"
export CHROME_USER_FLAGS="--ignore-gpu-blacklist"

#-----------------------------
# Dircolors
#-----------------------------

LS_COLORS='rs=0:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:tw=30;42:ow=34;42:st=37;44:ex=01;32:';
export LS_COLORS

#------------------------------
# Keybindings
#------------------------------
#bindkey -v
#typeset -g -A key
#bindkey '\e[3~' delete-char
#bindkey '\e[1~' beginning-of-line
#bindkey '\e[4~' end-of-line
#bindkey '\e[2~' overwrite-mode
#bindkey '^?' backward-delete-char
#bindkey '^[[1~' beginning-of-line
#bindkey '^[[5~' up-line-or-history
#bindkey '^[[3~' delete-char
#bindkey '^[[4~' end-of-line
#bindkey '^[[6~' down-line-or-history
#bindkey '^[[A' up-line-or-search
#bindkey '^[[D' backward-char
#bindkey '^[[B' down-line-or-search
#bindkey '^[[C' forward-char 
# for rxvt
#bindkey "\e[8~" end-of-line
#bindkey "\e[7~" beginning-of-line
# for gnome-terminal
#bindkey "\eOH" beginning-of-line
#bindkey "\eOF" end-of-line

#------------------------------
# Alias stuff# key bindings
bindkey "\e[1~" beginning-of-line
bindkey "\e[4~" end-of-line
bindkey "\e[5~" beginning-of-history
bindkey "\e[6~" end-of-history
bindkey "\e[3~" delete-char
bindkey "\e[2~" quoted-insert
bindkey "\e[5C" forward-word
bindkey "\eOc" emacs-forward-word
bindkey "\e[5D" backward-word
bindkey "\eOd" emacs-backward-word
bindkey "\e\e[C" forward-word
bindkey "\e\e[D" backward-word
bindkey "^H" backward-delete-word
# for rxvt
bindkey "\e[8~" end-of-line
bindkey "\e[7~" beginning-of-line
# for non RH/Debian xterm, cant hurt for RH/DEbian xterm
bindkey "\eOH" beginning-of-line
bindkey "\eOF" end-of-line
# for freebsd console
bindkey "\e[H" beginning-of-line
bindkey "\e[F" end-of-line
# completion in the middle of a line
bindkey '^i' expand-or-complete-prefix

#------------------------------
alias ls='ls --color=auto -F'
alias grep='grep --color=tty -d skip'
alias cp='cp -v'
alias mv='mv -v'
alias gitup='git fetch origin && git merge origin/master'
alias diff=colordiff
alias mvn=~/bin/mvn
alias hoogle="hoogle --color"
#alias _cd="cd"
#alias cd="chpwd"

#xmodmap -e "remove lock = Caps_Lock" &> /dev/null

langinit() {
    mkdir cur old work
}

#------------------------------
# Comp stuff
#------------------------------
zmodload zsh/complist
autoload -Uz compinit
compinit
zstyle :compinstall filename '${HOME}/.zshrc'

zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*'   force-list always

zstyle ':completion:*:*:killall:*' menu yes select
zstyle ':completion:*:killall:*'   force-list always

#------------------------------
# Window title
#------------------------------
case $TERM in
    *xterm*|rxvt|rxvt-unicode|rxvt-256color|(dt|k|E)term)
		precmd () { print -Pn "\e]0;[%n@%M]%# [%~]\a" }
		preexec () { print -Pn "\e]0;[%n@%M]%# [%~] ($1)\a" }
	;;
    screen)
                precmd () {
			print -Pn "\e]83;title \"$1\"\a"
			print -Pn "\e]0;$TERM - (%L) [%n@%M]%# [%~]\a"
		}
		preexec () {
			print -Pn "\e]83;title \"$1\"\a"
			print -Pn "\e]0;$TERM - (%L) [%n@%M]%# [%~] ($1)\a"
		}
	;;
esac


#------------------------------
# Prompt
#------------------------------


git_prompt () {
    if [[ $current_prompt == "git" ]]; then
        return
    fi

    current_prompt="git"

    branch=$(git status | head -n1 | sed "s/# On branch //")
    modified=$(git status | grep "modified")

    if [[ $modified == "" ]]; then
        COLOR=
    else;
        COLOR=${PR_RED}
    fi

    PS1="%1d/ ${COLOR}$branch${PR_NO_COLOR} ${PR_CYAN}%#${PR_NO_COLOR} "
}

chpwd () {
    if [[ -d .git/ ]]; then
  #      git_prompt
    elif [[ $current_prompt == "git" ]]; then
        setprompt
    fi

}

setprompt () {
    # load some modules

    autoload -U colors zsh/terminfo
    colors
    setopt prompt_subst

    for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
            eval PR_$color='%{$fg[${(L)color}]%}'
    done
    PR_NO_COLOR="%{$terminfo[sgr0]%}"

    # Check the UID
    if [[ $UID -ge 1000 ]]; then # normal user
        eval PR_USER='%n'

        eval PR_USER_OP='${PR_CYAN}%#${PR_NO_COLOR}'
    elif [[ $UID -eq 0 ]]; then # root
        eval PR_USER='${PR_RED}%n${PR_NO_COLOR}'
        eval PR_USER_OP='${PR_RED}%#${PR_NO_COLOR}'
    fi

    if [[ -z $SSH_CONNECTION ]]; then
        PS1=$'$PR_USER %~ $PR_USER_OP '
    else
        PS1=$'$PR_USER->${PR_BLUE}%M${PR_NO_COLOR} %~ $PR_USER_OP '
    fi

    # set the prompt
    #PS1=$'${PR_CYAN}[${PR_USER}${PR_CYAN}@${PR_HOST}${PR_CYAN}][${PR_BLUE}%~${PR_CYAN}]${PR_USER_OP} '
    PS2=$'%_>'
    current_prompt=""
}

setprompt
#vim: set ft=sh
