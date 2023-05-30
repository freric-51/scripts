#!/usr/bin/env bash
#
#	30 FG ~ 40 BG ~ n + 60 Bright
#	30 Black	31 Red		32 Green	33 Yellow
#	34 Blue		35 Magenta	36 Cyan		37 White
COLOR_RESET='\033[0m'
COLOR_RED='\033[31m'
COLOR_GREEN='\033[32m'
COLOR_YELLLOW='\033[33m'
COLOR_BLUE='\033[34m'
COLOR_WHITE='\033[37m'
COLOR_WHITE_ON_BLACK='\033[37;40m'
COLOR_BLACK_ON_WHITE='\033[30;47m'
COLOR_RED_ON_GREEN='\033[31;42m'
COLOR_WHITE_ON_CYAN='\033[37;46m'

# $0 The name of the bash script.
PROGRAM_NAME=`basename $0 | tr 'a-z' 'A-Z'`
echo -e "$PROGRAM_NAME  ${COLOR_BLUE}v-2023${COLOR_RESET}"

dir_base=$(pwd | rev | cut -d"/" -f2- | rev)
dir_repo="/$(pwd | rev |cut -d"/" -f1 | rev)"

# echo -e "\n"

case $1 in
clone)
	echo -e "${COLOR_GREEN}clone:${COLOR_RESET}"
	git clone https://github.com/freric-51$dir_repo
	cd "$dir_base$dir_repo"
    git status
	;;

status)
	cd "$dir_base$dir_repo"
	git config --global user.name "freric-51"
	git config --global user.email "ricdefreitas@hotmail.com"
	git config --global color.ui true
	git config --global core.symlinks true
	echo -e "${COLOR_GREEN}return of list: desconsidere gui.recentrepo${COLOR_RESET}"
	git config --list
	echo -e "${COLOR_GREEN}return of status:${COLOR_RESET}"
	git status
	;;

pull)
	cd "$dir_base$dir_repo"
    git status
	git pull --verbose
	;;

push)
    cd "$dir_base$dir_repo"
    git status
    git commit -a -m "file synchronization"
    #git push REPO main
    git push
	;;

branchs)
    cd "$dir_base$dir_repo"
    git status
    git branch -vva
    ;;

*)
    echo -e "${COLOR_RED}git status"
    echo "git add"
    echo "git commit"
    echo -e "git push (após commit)${COLOR_RESET}"
    echo -e "${COLOR_BLUE}git_repo.sh status push ${COLOR_RESET}/ pull branchss"
    ;;
esac

cd "$dir_base"
# echo -e "\n"
