#!/usr/bin/env bash

# Freitas 05/27/2023
# trap null return from ping with 'if -z' after line 80

# Freitas May 22 2023
# if there is no wifi then exit

# Freitas April 26 2023
# kernel  5.15.0-70-generic
# keep wifi working
# if it stops then off/on the radio to force reconnecting

# Freitas Jun 17 2023
# Split calls into  functions

source terminal_colors.sh

# percentagem de sinal considerado muito fraco
MENOR_SINAL=-80

function find_device {
    # wifi devices start with WL
	cd "/sys/class/net/"
	ls -d wl*
}

function mac_AP {
    MAC=`iwconfig $1 2>/dev//null | grep -i access | sed -e 's/  */ /g' | cut -d":" -f4-`
    if [[ -z $MAC ]]; then
        MAC="00:00:00:00"
    fi
    echo $MAC
}

function turn_on_network() {
    NET=`nmcli networking`
    if [ $NET == "disabled" ]; then
        nmcli networking on
        sleep 2
    fi
    NET=`nmcli networking`

    if [ $NET == "enabled" ]; then NET=1; else NET=0; fi
    echo $NET
}

function turn_on_radio() {
    RADIO=`nmcli radio wifi`
    if [ $RADIO == "disabled" ]; then
        nmcli radio wifi on
        sleep 20
    fi
    RADIO=`nmcli radio wifi`
    if [ $RADIO == "enabled" ]; then RADIO=1; else RADIO=0; fi
    echo $RADIO
}

function current_ESSID() {
    # ESSID=`iwconfig $1 2>/dev/null | grep ESSID | cut -d" " -f8 `
    # ESSID=`iwconfig $1 2>/dev/null | grep ESSID | cut -d":" -f2 | awk -F'"' '{print "ESSID:\"" $2 "\""}' `
    ESSID=`iwconfig $1 2>/dev/null | grep ESSID | cut -d":" -f2 | awk -F'"' '{print "\"" $2 "\""}' `
    echo $ESSID
}

function is_ping() {
    # 1 pacotes transmitidos, 0 recebidos, 100% perda de pacote, tempo 0ms
    # 1 packets transmitted, 1 received, 0% packet loss, time 0ms
    # RECEbido ~ RECEived
    # com 2>/dev/null ping retorna vazio se a conexão não ocorrer, tratado com ' if -z'
    Received=`ping -c1 -q -W10 1.1.1.1 2>/dev/null | sed -r '/^[\s\t]*$/d' | grep -i "rece" | cut -f2 -d, | cut -d" " -f2`
    if [[ -z $Received ]]; then Received=0; fi
    echo $Received
}

function conn_to_first_wifi() {
    RUN=`nmcli device set $1 autoconnect yes`
    # RUN=`nmcli con show | grep wifi | cut -d" " -f1 | head -n 1 | xargs -I{}  nmcli con up id {}`
    RUN=`nmcli con show | grep wifi | cut -c-21 | sed -e 's/  */ /g'  | awk  '{print "\"" $0 "\""}' | sed -e 's/ " */"/g' | head -n 1 `
    RUN=`echo $RUN | xargs -I{}  nmcli con up id {}  2>/dev/null`
    if [[ -z $RUN ]]; then
        # error
        RUN=0
    else
        # Conexão ativada com sucesso (caminho D-Bus ativo: /org/freedesktop/NetworkManager/ActiveConnection/11)
        RUN=1
    fi
     echo $RUN
}

function Signal_Level() {
    # Quality=`iwconfig $1 2>/dev/null | grep -i 'link quality' | awk '{ print $2 }' | cut -d"=" -f2 | cut -d"/" -f1`
    level=`iwconfig $1 2>/dev/null | grep -i 'link quality' | awk '{ print $4 }' | cut -d"=" -f2 | cut -d"/" -f1`
    if [[ -z $level ]]; then level=-999; fi
    echo $level
}

function connected {
    # parameter: device name
    # return: 1= connected, 0= not

    # 4163 0x1043 = UP,BROADCAST,RUNNING,        MULTICAST
    # 4098 0x1002 =    BROADCAST,                MULTICAST
    # 8843 0x228b = UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST
    # NETFLAGS=`ifconfig $placa | grep -i flags | cut -f1 -d\< | cut -f2 -d=`
    # if [ $NETFLAGS -eq 4098 ]; then

    FUNCTIONAL=1

    OK=$(turn_on_network)
    if [ $OK -eq "0" ]; then FUNCTIONAL=0; fi

    OK=$(turn_on_radio)
    if [ $OK -eq "0" ]; then FUNCTIONAL=0; fi

    ESSID=$(current_ESSID $1)
    if  [ '""' == "$ESSID" ] ; then  FUNCTIONAL=0; fi

    if [ "$ESSID" == 'off/any' ]; then
        # try to connect to first wifi ESSID
        conn_to_first_wifi $1
        sleep 20
        FUNCTIONAL=0
    else
        SigLevel=$(Signal_Level $1)
        if [ $SigLevel -lt $MENOR_SINAL ]; then FUNCTIONAL=0; fi

        Received=$(is_ping)
        if [ $Received -eq 0 ]; then FUNCTIONAL=0; fi
    fi

    echo $FUNCTIONAL
}

# #######################
#  MAIN
# #######################

# $0 The name of the bash script.
PROGRAM_NAME=`basename $0 | tr 'a-z' 'A-Z'`
echo -e "$PROGRAM_NAME  ${COLOR_RED}v-2023${COLOR_RESET}"

placa=$(find_device)
if [[ -z $placa ]] ; then
    echo -e "${COLOR_RED}Nenhuma $placa wifi encontrada\nabortando o controle${COLOR_RESET}"
    exit
fi

echo -e "${COLOR_RED}Monitoração wifi de $placa ${COLOR_RESET}"

# ===================
# Teste das funções
# ===================
TEST=0
if [ $TEST -eq 1 ]; then
    echo $(turn_on_network)
    echo $(turn_on_radio)

    ESSID=$(current_ESSID $placa)
    if  [ '""' == "$ESSID" ] ; then
        echo "unable to connect to wifi"
    else
        echo $ESSID
    fi

    echo $(is_ping)
    echo $(conn_to_first_wifi $placa)
    echo $(Signal_Level $placa)
    echo $(mac_AP $placa)

    echo "FIM"
    exit
fi
# ==============================================================================

SAI_n=999
MAC=$(mac_AP $placa)

while [ 1 -ne $SAI_n ]; do
	cnn=$(connected $placa)
	if [ "$cnn" -eq "1" ] ; then
		sleep 0.1
        MAC=$(mac_AP $placa)
	else
		echo -e "$cnn offline - `date +%H:%M:%S` at $MAC"
        sleep 0.1
        echo -e "${COLOR_RED}\tstopping wifi ... ${COLOR_RESET}"
        # sudo service network-manager stop
        nmcli radio wifi off
        sleep 5
        echo -e "${COLOR_RED}\tstarting wifi ... ${COLOR_RESET}"
        # sudo service network-manager start
        nmcli radio wifi on
	fi

    for i in {0..6}; do
        trap SAI_n=1 SIGHUP SIGINT SIGTERM
        if [ 1 -eq $SAI_n ]; then
            echo -e "${COLOR_RED}saindo.${COLOR_RESET}"
            sleep 3
            break
        else
            sleep 11
        fi
    done

done

echo -e "Fim monitoramento da conexão wifi${COLOR_RESET}"
