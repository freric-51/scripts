#!/usr/bin/env bash

source /home/ric/bin/terminal_colors.sh

if [ -z "$1" ] ; then
	echo -e "${COLOR_RED}Não foi fornecido parametro. É esperado [1,2]"

elif [ "1" == $1 ] ; then
	echo -e "${COLOR_GREEN}"
	protonvpn-cli login freric0810
	protonvpn-cli connect --random --protocol tcp

elif [ "2" == $1 ] ; then
	echo -e "${COLOR_BLUE}"
	protonvpn-cli disconnect

else
	echo -e "\t<-${COLOR_RED_ON_GREEN} $1 ${COLOR_RESET}-> ${COLOR_RED}não é parametro esperado [1,2]\n"

fi

echo -e "${COLOR_WHITE}"
protonvpn-cli status
echo -e "${COLOR_RESET}"
