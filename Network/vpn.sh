#!/usr/bin/env bash

       COLOR_RESET='\033[0m'
         COLOR_RED='\033[31;40m'
       COLOR_GREEN='\033[32;40m'
        COLOR_BLUE='\033[34;40m'
       COLOR_WHITE='\033[37;40m'
COLOR_RED_ON_GREEN='\033[31;42m'

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
