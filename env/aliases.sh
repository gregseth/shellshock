##                                                                            ##
#                                                                              #
#                                   ALIASES                                    #
#                                                                              #
##                                                                            ##

################################################################################
# Common commands shortcuts                                                    #
################################################################################

# Listing dirs
if ls --color=always &> /dev/null
then
	alias ls='ls -F --color=always'
else
	alias ls='ls -F'
fi
 
alias l='ls'
alias ll='ls -lh'
alias la='ls -a'
alias lla='ls -alh'
function mkcd {
    mkdir "$1" && cd "$1"
}

alias lsports="sudo lsof -i"

alias path='echo $PATH | tr ":" "\n"'

alias movies-to-watch='ls /giediprime/Video/Films/._* | cut -d_ -f2 | sed "s/\.avi.*$//"'
alias motd='cat /etc/motd'

# The following requires the patched-corutils package
# Used to show adbvancement status when moving or copying files
# Can be found at: http://true-wing.livejournal.com/53739.html
touch /tmp/test-cpmv-g
if mv -g /tmp/test-cpmv-g /tmp/test-cpmv-g.bak &> /dev/null
then
    alias cp='cp -ig'
    alias mv='mv -ig'
else
    alias cp='cp -i'
    alias mv='mv -i'
fi
rm /tmp/test-cpmv* &> /dev/null

function subst {
    if [ $# -ne 2 ]
    then 
        echo "Usage: $0 <dir> <pattern>"
        return 1
    else
        mv "$1" "__$1"
        
        if [ -d "__$1" ]
        then 
            find "__$1" -mindepth 1 -iname "$2" -exec mv {} "$1" \;
            
            if [ -f "$1" ]
            then
                rm -r "__$1"
            else
                # rollback if failed
                #mv "__$1" "$1"
                return 3
            fi
        else
            return 2
        fi
    fi
}

# Acting as root
alias root='sudo -s'
alias suno='sudo $EDITOR'
alias ssudo='sudo sh -c'
alias ifconfig='/sbin/ifconfig'
alias arp='/usr/sbin/arp'
alias showlog='tac /var/log/syslog | more'
alias SYSLOG='tail -F /var/log/syslog'

function apt-update-all {
	if [ `whoami` = 'root' ]
	then
		apt-get update
		apt-get upgrade
		apt-get dist-upgrade
		apt-get autoremove --purge

		echo > /tmp/upgradable-packages
	else
		echo "Must be superuser"
	fi
}
alias apt-list-updates="ssudo 'apt-get update > /dev/null 2>&1 && apt-get upgrade -usy | grep \ \  -A 1'"

# General
alias grep='egrep'
alias cgrep='grep --color=always'
alias ps='ps aux'
alias psg='ps | grep -v grep | grep -i'
alias bs='xset dpms force standby'
alias fantemp='sensors | grep "(Core|fan1|temp1)"'
alias speedtest='wget --output-document=/dev/null http://speedtest.wdc01.softlayer.com/downloads/test500.zip'
#real clear still available with Ctrl-l
alias banner='clear && capscreen.sh'

alias emacs='emacs -nw'
alias ln='ln -si'

alias bepo='setxkbmap fr bepo'
alias wanip='wget -q http://checkip.dyndns.org -O- | cut -d: -f2 | cut -d\< -f1'

function blockip {
	iptables -A INPUT -s $1 -j DROP
}

alias iso2utf="iconv -f ISO-8859-1 -t UTF-8"
alias win2utf="iconv -f CP850 -t UTF-8"

################################################################################
# Special functions                                                            #
################################################################################

# Tools
alias trim='sed -r "s/^[ \t]*|[ \t]*$//g"'
alias nettest='ping -c 1 google.com &> /dev/null && echo +OK || echo -KO'

alias tweet='twidge update'

# screen
alias sc='screen'
alias scls='screen -ls'
alias scl='screen -ls'
alias scfrm='screen -c ~/.screenrc_frame -S'
alias scdr='screen -dr'
alias sdr='screen -dr'
alias scdra='screen -e"^Aa" -dr'
alias scdrz='screen -e"^Zz" -dr'
alias scdre='screen -e"^Ee" -dr'

# Fun
alias topten="sed -e 's/^: [0-9]\{10\}:0;//' ~/.zshist | sed -e 's/sudo //' | \
	cut -d' ' -f1 | sort | uniq -c | sort -rg | head"
function let-it-snow {
    clear
    while :
    do 
        echo $LINES $COLUMNS $(($RANDOM%$COLUMNS))
        sleep 0.1
    done | gawk '{a[$3]=0;for(x in a) {o=a[x];a[x]=a[x]+1;printf "\033[%s;%sH ",o,x;printf "\033[%s;%sH*\033[0;0H",a[x],x;}}'
}

function clock {
#   cnt=$[ $[ $COLUMNS - 110 ] / 2 ]
#   spacer=$(rpt $cnt ' ')

    while :
    do
        clear
        date "+%H : %M : %S" | figlet -w $COLUMNS -c -f computer #graffiti
        sleep 10
    done
}
# Line counter for C++ source files
function cl {
	echo Written line: $(cat */src/*.{cpp,h} | wc -l)
	echo "Total (including auto-generated files):" $(cat */*/*.{cpp,h} | wc -l)
}

function resolve-tiny-url {
    wget $1 -O /dev/null 2>&1 | grep Emplacement | cut -d\  -f 2
}

function swap {
    local TMPFILE=tmp.$$
    mv "$1" $TMPFILE
    mv "$2" "$1"
    mv $TMPFILE "$2"
}

function ssh-sendkey {
    KEY=$(cat ~/.ssh/id_rsa.pub)
    ssh "$@" "[ -d ~/.ssh ] || mkdir ~/.ssh; echo '$KEY' >> ~/.ssh/authorized_keys"
}

function alignc {
    local OPT
    local W=$COLUMNS

    getopts n: OPT
    [ $OPT ] && [ $OPT = "n" ] && W=$OPTARG
    shift $[$OPTIND-1]

    if [ $# -eq 0 ]
    then
		echo "Usage: $0 [-n N] STRING"
		return 1
    else
		local L=$(expr length "$*")
		printf "%$[($W+$L)/2]s\n" "$*"
    fi
}

function alignr {
    local OPT
    local W=$COLUMNS

    getopts n: OPT
    [ $OPT ] && [ $OPT = "n" ] && W=$OPTARG
    shift $[$OPTIND-1]

    if [ $# -eq 0 ]
    then
		echo "Usage: $0 [-n N] STRING"
		return 1
    else
		printf "%${W}s\n" "$*"
    fi
}

function rpt {
    if [ $# -ne 2 ]
    then
		echo "Usage: $0 N STRING"
		return 1
    else
		local i=0
		local str
		while [ $i -lt $1 ]
		do
		    str="$2$str"
			i=$[$i+1]
		done
		echo -n $str
    fi
}
alias pad=rpt

function spin {
	i=0
	printf ' '

	while [ $i -lt $1 ]
	do
		printf "\b\\"
		sleep .333
		printf "\b/"
		sleep .333
		printf "\b-"
		sleep .333

		i=$[$i+1]
	done

	echo
}

function progress {
    if [ $# -ne 2 ]
    then
		echo "Usage: progress WIDTH %ADVANCEMENT"
		return 1
    else
		[ $[$1+8] -gt $COLUMNS ] && W=$[$COLUMNS-8] || W=$1
		local s=$[$W*$2/100]
		[ $2 -ne 0 ] && rpt $[$W+8] "\b"
		printf "[%s%s%s] %3s %%" "$(rpt $s '=')" "$([ $2 -ne 100 ] && echo '>')"  "$(rpt $[$W-$s-1] ' ')" "$2"
		[ $2 -eq 100 ] && echo
    fi
}

function find_in {
	rc=1

	verbose=false;
	if [ $1 = "-v" ]
	then
		verbose=true
		shift
	fi

	echo "Looking for '$2' in '$1'"
    find "$1" -type f | while read f
    do
		$verbose && echo "Analyzing $f..."
		# file prevents processing binary files
        if ( ( file "$f" | grep text &> /dev/null ) && egrep --color=always -in "$2" "$f" )
        then
            dashCnt=$[$COLUMNS - ${#f} - 3]
	        printf "^%s{ %s\n" $(rpt $dashCnt -) "$f"
	        rc=0
        fi
    done
    return $rc
}

function ffind_in  {
    ( find_in "$1" "$3" || find_in "$2" "$3" ) && return 0 || return 1
}

# Pretty prints the current $PATH variables (each directory on one line).
function echopath {
    p=$PATH
    while [ "$d" != "$p" ]
    do
		d=${p%%:*}
		p=${p#*:}
		echo $d
	done
}

# Converts a time in seconds to hours:minutes:seconds
function sec2hms {
    h=$[ $1 /3600 ]
    m=$[ $1 %3600 /60 ]
    s=$[ $1 %60 ]
	printf "%d:%02d:%02d" $h $m $s
}

function countdown {
	if [ $1 ]
	then
		i=0
		printf "\r%s %s" "$2" $(sec2hms $1)
		while [ $i -lt $1 ]
		do
			i=$[ $i + 1 ]
			sleep 1
			printf "\r%s %s" "$2" $(sec2hms $[ $1 - $i ])
		done

		echo
	fi
}

function hpp-title {
#	echo "  $(rpt 78 /)"
#	echo " $(rpt 79 /)"
#	figlet -f chunky -w 76 -c "$*" | awk '{ printf("%-76s\n", $0) }' | sed -e "s:^://:" -e "s:$://:"
#	echo "//$(rpt 76 ' ')//"
#	echo "$(rpt 79 /) "
#	echo "$(rpt 78 /)  "

	figlet -f chunky -w 76 -c "$*" | boxes -i text -d codra -s 80x1
}

################################################################################
# X11 apps                                                                     #
################################################################################

alias gterm="gnome-terminal --geometry=120x32+180+150 --title=desktop-shell &"


################################################################################
# Unsorted aliases (added with echo ... >> .zshrc_aliases)                     #
################################################################################

function nebashfr {
    while true
    do
	bashfr.pl
	echo `rpt $COLUMNS -`
	sleep 20
    done
}

alias qtmake='qmake -project && qmake && make'
function pbar {
    printf "\r%s%s %03i %%" ${(r:$1::-::|:)} ${(l:$[${2=100}+1-$1]:: ::|:)} $1
}

function vid {
    totem "$1" &> /dev/null &
}

function fizzbuzz {
	for i in {1..100}
	do
		str=""
		[ $[$i % 3] -eq 0 ] && val="Fizz"
		[ $[$i % 5] -eq 0 ] && val="${val}Buzz"
		[ -z $val ] 		&& val=$i

		echo $val
	done
}

function extract {
    if [ -f $1 ] ; then
      case $1 in
        *.tar.bz2)   tar xjf $1     ;;
        *.tar.gz)    tar xzf $1     ;;
        *.bz2)       bunzip2 $1     ;;
        *.rar)       unrar e $1     ;;
        *.gz)        gunzip $1      ;;
        *.tar)       tar xf $1      ;;
        *.tbz2)      tar xjf $1     ;;
        *.tgz)       tar xzf $1     ;;
        *.zip)       unzip $1       ;;
        *.Z)         uncompress $1  ;;
        *.7z)        7z x $1        ;;
        *)     echo "'$1' cannot be extracted via extract()" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}


function mcd() {
  mkdir -p "$1" && cd "$1";
}

function print_acs() {
    typeset -A ACS                                                            
    set -A ACS ${(s..)terminfo[acsc]}                                         
                                                                                        
    for l in $ACS                                                             
    do                                                                        
        echo "$l ($ACS[$l]) : $terminfo[smacs]${ACS[$l]:--}$terminfo[rmacs]"
    done
}


