# profile for zsh(1)
if [ -x /usr/libexec/path_helper ]
then
	eval `/usr/libexec/path_helper -s`
fi

[ -f $HOME/.env.local ] && source $HOME/.env.local

if [[ -d .env ]]
then
    for rc in .env/*
    do
        source $rc
    done
fi

git_super_status () {} 
[ -f $HOME/Dropbox/Scripts/zsh-git-prompt.sh ] && source $HOME/Dropbox/Scripts/zsh-git-prompt.sh

setopt AUTO_CD
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt NO_HIST_BEEP
setopt EXTENDED_GLOB

precmd () {

    local TERMWIDTH
    (( TERMWIDTH = ${COLUMNS} - 1 )) 

    ###
    # Truncate the path if it's too long.
    
    PR_FILLBAR=""
    PR_PWDLEN=""
    
    local promptsize=${#${(%):--(%D{%Y:%m:%d@%H:%M:%S})()-}}
    local pwdsize=${#${(%):-%~}}
    local maxpwd=$[$TERMWIDTH-$promptsize-10]
    
    HBAR="${(l.(($TERMWIDTH - ($promptsize + $pwdsize)))..-.)}"
   
    echo
    echo "-|$TT_BOLD$FG_GREEN$(date +%Y:%m:%d@%H:%M:%S)$TT_RESET|$HBAR|$TT_BOLD$FG_MAGENTA${(%)${:-%$maxpwd<...<%~%<<}}$TT_RESET|-"
    
}

preexec () {
    if [[ "$TERM" == "screen" ]]
    then
		local RMK=""
		
		if [ "$(whoami)" = "root" ] || [ "${${(z)1}[1]}" = "sudo" ]
		then
			RMK=':' 
		fi
        local CMD=${1[(wr)^(*=*|sudo|-*)]}
        settitle "${RMK}${TITLE:-$CMD}"
    fi
}

terminit()
{
    # determine the window title escape sequences
    case "$TERM" in
    aixterm|dtterm|putty|rxvt|xterm*)
        titlestart='\033]0;'
        titlefinish='\007'
        ;;
    cygwin)
        titlestart='\033];'
        titlefinish='\007'
        ;;
    konsole)
        titlestart='\033]30;'
        titlefinish='\007'
        ;;
    screen*)
        # status line
        #titlestart='\033_'
        #titlefinish='\033\'
        # window title
        titlestart='\033k'
        titlefinish='\033\'
        ;;
    *)
        if type tput >/dev/null 2>&1
        then
            if tput longname >/dev/null 2>&1
            then
                titlestart="$(tput tsl)"
                titlefinish="$(tput fsl)"
            fi
        else
            titlestart=''
            titlefinish=''
        fi
        ;;
    esac
}

# or put it inside a case $- in *i* guard
if test -t 0; then
    terminit
fi

# set the xterm/screen/etc. title
settitle() {
    test -z "${titlestart}" && return 0
    printf "${titlestart}$*${titlefinish}"
}


setprompt () {
    ###
    # Need this so the prompt will work.

    setopt prompt_subst

    ###
    # See if we can use colors.

	autoload colors zsh/terminfo
	if [[ "$terminfo[colors]" -ge 8 ]]
	then
        colors
	fi
	for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE
	do
        eval PR_BG_$color='%{$bg[${(L)color}]%}'
	    eval PR_$color='%{$fg[${(L)color}]%}'
	    eval PR_B_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
	    eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
        eval PR_LIGHT_B_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
        (( count = $count + 1 ))
	done
	PR_NO_COLOUR="%{$terminfo[sgr0]%}"
	PR_BOLD="%{$terminfo[bold]%}"

    ###
    # Finally, the prompt.

    PS1='%(!.$PR_B_RED.)>>$PR_NO_COLOUR $PR_BOLD%(!.$PR_YELLOW.)%n@%m$PR_NO_COLOUR %(!.$PR_B_RED.)>>$PR_NO_COLOUR '

    RPS1='%(?..%(!.$PR_B_RED.)<<%(!.$PR_B_YELLOW.$PR_B_RED) %? $PR_NO_COLOUR)%(!.$PR_B_RED.)<<$(git_super_status)$PR_NO_COLOUR' 

    PS2='$PR_NO_COLOUR>> $PR_LIGHT_CYAN%_$PR_NO_COLOUR >> '
    RPS2='<<'

}

setprompt

# The following lines were added by compinstall
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*:*' get-revision true
zstyle ':vcs_info:git*:*' check-for-changes true

# hash changes branch misc
zstyle ':vcs_info:git*' formats "(%s) %12.12i %c%u %b%m"
zstyle ':vcs_info:git*' actionformats "(%s|%a) %12.12i %c%u %b%m"

function __git_prompt {
    local DIRTY="%{$fg[yellow]%}"
    local CLEAN="%{$fg[green]%}"
    local UNMERGED="%{$fg[red]%}"
    local RESET="%{$terminfo[sgr0]%}"
    git rev-parse --git-dir >& /dev/null
    if [[ $? == 0 ]]
    then
        echo -n " "
        if [[ `git ls-files -u >& /dev/null` == '' ]]
        then
            git diff --quiet >& /dev/null
            if [[ $? == 1 ]]
            then
                echo -n $DIRTY
            else
                git diff --cached --quiet >& /dev/null
                if [[ $? == 1 ]]
                then
                    echo -n $DIRTY
                else
                    echo -n $CLEAN
                fi
            fi
        else
            echo -n $UNMERGED
        fi
        echo -n `git branch | grep '* ' | sed 's/..//'`
        echo -n $RESET
        echo -n " <<"
    fi
}


zstyle ':completion:*' add-space true
zstyle ':completion:*' completer _expand _complete _ignored _match _correct _approximate _prefix
zstyle ':completion:*' expand suffix
zstyle ':completion:*' file-sort name
zstyle ':completion:*' group-name ''
zstyle ':completion:*' ignore-parents parent pwd directory
#zstyle ':completion:*' insert-unambiguous true
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-suffixes true
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' match-original both
#zstyle ':completion:*' max-errors 2 numeric
zstyle ':completion:*' menu select=5
zstyle ':completion:*' old-menu false
zstyle ':completion:*' original true
zstyle ':completion:*' preserve-prefix '//[^/]##/'
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' verbose true
zstyle ':completion:*' word true
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always
zmodload -i zsh/complist
zstyle :compinstall filename '/home/seth/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Use emacs keybindings even if our EDITOR is set to vi
# (meaning the Ctrl-t, Ctrl-k are functionning)
bindkey -e

if [[ ! $HOME == /cyg* ]]
then
    stty erase 
fi

autoload zkbd
[[ ! -d ~/.zkbd ]] && mkdir ~/.zkbd
##[[ ! -f ~/.zkbd/$TERM-$VENDOR-$OSTYPE ]] && zkbd
if [[ $(uname) != "Darwin" ]] 
then
    if [ -f  ~/.zkbd/$TERM-$VENDOR-$OSTYPE ]
    then
        source  ~/.zkbd/$TERM-$VENDOR-$OSTYPE
        # setup key accordingly
        [[ -n "${key[Home]}"    ]]  && bindkey  "${key[Home]}"    beginning-of-line
        [[ -n "${key[End]}"     ]]  && bindkey  "${key[End]}"     end-of-line
        [[ -n "${key[Insert]}"  ]]  && bindkey  "${key[Insert]}"  overwrite-mode
        [[ -n "${key[Delete]}"  ]]  && bindkey  "${key[Delete]}"  delete-char
        [[ -n "${key[Up]}"      ]]  && bindkey  "${key[Up]}"      up-line-or-history
        [[ -n "${key[Down]}"    ]]  && bindkey  "${key[Down]}"    down-line-or-history
        [[ -n "${key[Left]}"    ]]  && bindkey  "${key[Left]}"    backward-char
        [[ -n "${key[Right]}"   ]]  && bindkey  "${key[Right]}"   forward-char
    fi
fi

# EOF

