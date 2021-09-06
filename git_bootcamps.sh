#!/usr/bin/env bash
dir_base="/media/Dados/Documentos/code/GitHub"
dir_repo="/bootcamps"

clear

case $1 in
clone)
	echo -e "\nclone:"
	git clone https://github.com/freric-51$dir_repo
	cd "$dir_base$dir_repo"
	;;
	
status)	
	cd "$dir_base$dir_repo"
	git config --global user.name "freric-51"
	git config --global user.email "ricdefreitas@hotmail.com"
	git config --global color.ui true
	echo -e "nreturn of list: desconsidere gui.recentrepo"
	git config --list
	echo -e "\nreturn of status:"
	git status	
	;;

pull)
	cd "$dir_base$dir_repo"
	git pull --verbose
	;;
	
push)
	#cd "$dir_base$dir_repo"
	#git push bootcamps main
	;;
	

esac

cd "$dir_base"

echo "git status"
echo "git add"
echo "git commit"
echo "git push"



