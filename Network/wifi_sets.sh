#!/usr/bin/env bash

# Freitas May 22 2023
# if there is no wifi then exit

# Freitas April 26 2023
# kernel  5.15.0-70-generic
# keep wifi working
# if it stops then off/on the radio to force reconnecting


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

function find_device {
    # wifi devices start with WL
	cd "/sys/class/net/"
	ls -d wl*
}

function connected {
    # parameter: device name
    # return: 1= connected, 0= not

    # 4163 0x1043 = UP,BROADCAST,RUNNING,        MULTICAST
    # 4098 0x1002 =    BROADCAST,                MULTICAST
    # 8843 0x228b = UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST
    # NETFLAGS=`ifconfig $placa | grep -i flags | cut -f1 -d\< | cut -f2 -d=`
    # if [ $NETFLAGS -eq 4098 ]; then

    NET=`nmcli networking`
    if [ $NET == "disabled" ]; then
        nmcli networking on
        sleep 2
    fi

    RADIO=`nmcli radio wifi`
    if [ $RADIO == "disabled" ]; then
        nmcli radio wifi on
        sleep 20
    fi

    ESSID=`iwconfig $1 | grep ESSID | cut -d" " -f8 `
    RESULT=$?
    for ESSIDline in $ESSID; do
        if [[ $ESSIDline == *"ESSID"* ]]; then
            ESSID=`echo $ESSIDline | cut -d" " -f8 `
        fi
    done

    if [ $RESULT -eq 0 ] ; then
        if [ $ESSID == 'ESSID:off/any' ]; then
            # try to connect to first wifi ESSID
            RUN=`nmcli device set $1 autoconnect yes`
            RUN=`nmcli con show | grep wifi | cut -d" " -f1 | head -n 1 | xargs -I{}  nmcli con up id {}`
            sleep 20
            FUNCTIONAL=0
        else
            Quality=`iwconfig $1 | grep -i 'link quality' | awk '{ print $2 }' | cut -d"=" -f2 | cut -d"/" -f1`
            RESULT=$?
            if [ $RESULT -eq 0 ] ; then
                if [ $Quality -lt 20 ]; then
                    FUNCTIONAL=0
                else
                    # 1 pacotes transmitidos, 0 recebidos, 100% perda de pacote, tempo 0ms
                    # 1 packets transmitted, 1 received, 0% packet loss, time 0ms
                    # RECEbido ~ RECEived
                    Received=`ping -c1 -q -W10 1.1.1.1 | sed -r '/^[\s\t]*$/d' | grep -i "rece" | cut -f2 -d, | cut -d" " -f2`
                    if [ $Received -eq 0 ]; then FUNCTIONAL=0; else FUNCTIONAL=1; fi
                fi
            else
                # error executing shell
                FUNCTIONAL=0
            fi
        fi
    else
        # error executing shell
        FUNCTIONAL=0
    fi
    echo $FUNCTIONAL
}

# =======
#  MAIN
# =======

# $0 The name of the bash script.
PROGRAM_NAME=`basename $0 | tr 'a-z' 'A-Z'`
echo -e "$PROGRAM_NAME  ${COLOR_RED}v-2023${COLOR_RESET}"

placa=$(find_device)
if [[ -z $placa ]] ; then
    echo -e "${COLOR_RED}Nenhuma $placa wifi encontrada\nabortando o controle${COLOR_RESET}"
    exit
fi

echo -e "${COLOR_RED}Monitoração wifi de $placa ${COLOR_RESET}"

SAI_n=999
while [ 1 -ne $SAI_n ]; do
	cnn=$(connected $placa)

	if [ $cnn -eq "1" ] ; then
		sleep 0.1
        # echo -e "$cnn online - `date +%H:%M:%S`"
	else
		echo -e "$cnn offline - `date +%H:%M:%S`"
        sleep 0.1
        echo -e "${COLOR_RED}\tstopping wifi ... ${COLOR_RESET}"
        # sudo service network-manager stop
        nmcli radio wifi off
        sleep 5
        echo -e "${COLOR_RED}\tstarting wifi ... ${COLOR_RESET}"
        # sudo service network-manager start
        nmcli radio wifi on
	fi

	trap SAI_n=1 SIGHUP SIGINT SIGTERM
	if [ 1 -eq $SAI_n ]; then
        echo -e "${COLOR_RED}saindo. ${COLOR_RESET}"
	else
    	for i in {0..4}; do
            sleep 11
        done
	fi

done

echo -e "${COLOR_RESET}"
