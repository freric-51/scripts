#!/usr/bin/env bash

# Freitas 2023 may
# trap null return from ping with 'if -z' after line 80
# if there is no wifi then exit

# Freitas 2023 april
# kernel  5.15.0-70-generic
# keep wifi working
# if it stops then off/on the radio to force reconnecting

# Freitas 2023 jun
# Split calls into  functions

# Freitas 2023 oct
# $() or `` run in a separeted shell and variables are not updated
# RETf must was created to pass the results and to avoid the use of $()

source terminal_colors.sh

# percentagem de sinal considerado muito fraco
MENOR_SINAL=-90
MOTIVO="Revisao em 2023-10-01"
RETf=""
ID_WIFI=1

function find_device () {
    # wifi devices start with WL
	cd "/sys/class/net/"
	ls -d wl*
}

function mac_AP () {
    local placa=$1
    # this is the same MAC=$() or MAC=``
    local MAC=$(iwconfig $placa 2>/dev//null | grep -i access | sed -e 's/  */ /g' | cut -d":" -f4-)
    if [[ -z $MAC ]]; then
        MAC="00:00:00:00"
    fi
    echo $MAC
}

function wifi_exist() {
    local External=""
    local Configured=$1
    # Configured=$(nmcli con show | grep wifi | cut -c-19 | sed -e 's/  */ /g'  | awk  '{print "\"" $0 "\""}' | sed -e 's/ " */"/g' | sed '{:q;N;s/\n/,/g;t q}')
    External=$(nmcli device wifi list | tail +2 | cut -c26-47 |  sed -e 's/  */ /g' | awk  '{print "\"" $0 "\""}'  | sed -e 's/ " */"/g'  | sed -e 's/"  */"/g' | sed '{:q;N;s/\n/,/g;t q}')

    if [[ "$External" == *"$Configured"* ]]; then
        echo 1
    else
        echo 0
    fi
}

function turn_on_network () {
    local NET=$(nmcli networking)
    if [ $NET == "disabled" ]; then
        MOTIVO+=", [W] Net was disabled"
        NET=$(nmcli networking on)
        sleep 3
    fi

    NET=$(nmcli networking)
    if [ $NET == "enabled" ]; then
        # MOTIVO+=", [I] network on"
        NET=1
    else
        MOTIVO+=", [F] nmcli - ${NET} - 2a tentativa"
        NET=0
    fi

    RETf=$NET
}

function turn_on_radio () {
    local RADIO=$(nmcli radio wifi)
    if [ $RADIO == "disabled" ]; then
        # MOTIVO+=", [W] Radio off or disabled"
        RADIO=$(nmcli radio wifi on)
        sleep 10
    fi

    RADIO=$(nmcli radio wifi)
    if [ $RADIO == "enabled" ]; then
        RADIO=1
    else
        MOTIVO+=", [F] radio - ${RADIO} - 2a tentativa"
        RADIO=0
    fi

    RETf=$RADIO
}

function current_ESSID () {
    local placa=$1
    local ESSID=""
    ESSID=$(iwconfig $placa 2>/dev/null | grep ESSID | cut -d":" -f2 | awk -F'"' '{print "\"" $2 "\""}' )
    echo $ESSID
}

function is_ping () {
    # 1 pacotes transmitidos, 0 recebidos, 100% perda de pacote, tempo 0ms
    # 1 packets transmitted, 1 received, 0% packet loss, time 0ms
    # RECEbido ~ RECEived
    # com 2>/dev/null ping retorna vazio se a conexão não ocorrer, tratado com ' if -z'
    local IP="8.8.4.4"
    local Received="???"

    Received=`ping -c1 -q -W3 ${IP} 2>/dev/null | sed  -r '/^[\s\t]*$/d' | grep -i "rece" | cut -f2 -d, | cut -d" " -f2`
    if [[ -z $Received ]]; then
        MOTIVO+=", [W] No ping against ${IP} `date +%H:%M:%S`"
        Received=0
    elif [[ $Received -eq "0" ]]; then
        MOTIVO+=", [W] No ping against ${IP} `date +%H:%M:%S`"
        Received=0
    fi

    RETf=$Received
}

function conn_to_a_wifi () {
    ### RUN=`nmcli con show | grep wifi | cut -d" " -f1 | head -n 1 | xargs -I{}  nmcli con up id {}`

    local placa=$1
    local netID=""
    local succeeded=1
    local RUN=`nmcli device set $placa autoconnect yes`

    exist=0
    while [ 0 -eq $exist ] ; do
        RUN=`nmcli con show | grep wifi | cut -c-19 | sed -e 's/  */ /g'  | awk  '{print "\"" $0 "\""}' | sed -e 's/ " */"/g' | sed ${ID_WIFI}'!d' `
        netID=$RUN
        if [[ -z ${netID} ]] ;  then
            ID_WIFI=1
        else
            exist=$(wifi_exist ${netID})
            if [[ 0 -eq $exist ]] ; then
                # MOTIVO+=" ${netID}=${ID_WIFI}"
                (( ID_WIFI+=1 ))
                sleep 0.1
            fi
        fi
    done

    if [[ -z ${RUN} ]] ;  then
        MOTIVO+=", [I] found end of wifi list"
        ID_WIFI=0
        succeeded=0
    else
        RUN=`echo $RUN | xargs -I{}  nmcli con up id {}  2>/dev/null`
        if [[ -z $RUN ]]; then
            # error
            # MOTIVO+=", [W] ${netID}"
            succeeded=0
        else
            MOTIVO+=", [I] connected to ${netID} #${ID_WIFI}"
            succeeded=1
        fi
    fi

    RETf=$succeeded
}

function Signal_Level () {
    local placa=$1
    local level
    ((level=MENOR_SINAL-1))
    level=`iwconfig $placa 2>/dev/null | grep -i 'link quality' | awk '{ print $4 }' | cut -d"=" -f2 | cut -d"/" -f1`
    if [[ -z $level ]]; then
        MOTIVO+=", [W] Low level"
        level=-999
    fi
    echo $level
}

function to_connect_with_wifi () {
    local placa=$1
    local FUNCTIONAL=1

    nmcli radio wifi off
    sleep 1

    turn_on_network
    OK=$RETf
    if [[ $OK -eq "0" ]] ; then
        MOTIVO+=", [F] turn_on_network returned ${OK}"
        FUNCTIONAL=0
    fi

    turn_on_radio
    OK=$RETf
    if [[ $OK -eq "0" ]] ; then
        MOTIVO+=", [F] turn_on_radio ${OK}"
        FUNCTIONAL=0
    fi

    if [ $FUNCTIONAL -eq "1" ] ; then
        ESSID=$(current_ESSID $placa)
        if [[ "$ESSID" == '""' ]] ; then
            FUNCTIONAL=2
            # MOTIVO+=", [W] ESSID vazio"
        fi
        if [ "$ESSID" == 'off/any' ] ; then
            FUNCTIONAL=2
            MOTIVO+=", [W] ESSID off any"
        fi
    fi

    if [ $FUNCTIONAL -eq "2" ] ; then
        # try to connect to first wifi ESSID
        conn_to_a_wifi $placa
        OK=$RETf
        if [[ $OK -eq "0" ]] ; then
            MOTIVO+=", [W] 'conn_to_a_wifi'"
            FUNCTIONAL=0;
        else
            FUNCTIONAL=1
            # MOTIVO+=", [I] Conseguiu conexão"
        fi
    fi

    if [ $FUNCTIONAL -eq "1" ] ; then
        SigLevel=$(Signal_Level $placa)
        if [[ $SigLevel -lt $MENOR_SINAL ]]; then
            MOTIVO+=", [I] Sinal ${SigLevel}"
            FUNCTIONAL=0
        fi

        # is_ping
        # Received=$RETf
        # if [[ $Received -eq 0 ]]; then
        #     sleep 3
        #     is_ping
        #     Received=$RETf
        # fi
        # if [[ $Received -eq 0 ]]; then
        #     FUNCTIONAL=0
        #     # MOTIVO+=", [W] Nao veio ping"
        # fi
    fi

    RETf=$FUNCTIONAL
}

# #######################
#  MAIN
# #######################

# $0 The name of the bash script.
PROGRAM_NAME=`basename $0 | tr 'a-z' 'A-Z'`
echo -e "$PROGRAM_NAME  ${COLOR_RED}v-2023${COLOR_RESET}"

placa=$(find_device)
if [[ -z $placa ]] ; then
    echo -e "${COLOR_RED}Nenhuma $placa wifi encontrada\n\rabortando o controle${COLOR_RESET}"
    exit
fi

echo -e "${COLOR_RED}Monitoração wifi de $placa ${COLOR_RESET}"
# nmcli device wifi list

# ==============================================================================
# Teste das funções
# ==============================================================================
TEST=0
if [[ $TEST -eq 1 ]]; then
    turn_on_network
    echo  "$MOTIVO,[W] turn_on_network = $RETf"
    MOTIVO=""

    turn_on_radio
    echo  "$MOTIVO,[W] turn_on_radio = $RETf"
    MOTIVO=""

    ESSID=$(current_ESSID $placa)
    if  [ '""' == "$ESSID" ] ; then
        echo -e "unable to connect to wifi\n\r"
    else
        echo "conected to ${ESSID}"
    fi

    is_ping
    echo  "$MOTIVO,[W] is_ping = $RETf"
    MOTIVO=""

    while [ $RETf -eq "0" ] ; do
        conn_to_a_wifi $placa
        echo  "$MOTIVO,[W] conn_to_a_wifi = $RETf"
        MOTIVO=""
        sleep 0.5
    done

    echo "Signal_Level = $(Signal_Level $placa)"
    echo "mac_AP = $(mac_AP $placa)"

    nmcli device wifi list
    echo -e "FIM\n\r"

    exit
fi
# ==============================================================================

SAI_n=999
MAC=$(mac_AP $placa)
# nmcli device wifi list

while [ 1 -ne $SAI_n ] ; do
    is_ping
    cnn=$RETf
    if [[ "$cnn" -eq "1" ]] ; then
        ciclos_de_espera=6
        MAC=`mac_AP $placa`
    else
        ciclos_de_espera=3
        echo -e "${COLOR_RED}Restarting wifi${COLOR_RESET} - `date +%H:%M:%S` at ${COLOR_YELLLOW}${MAC}${COLOR_RESET}"

        (( ID_WIFI+=1 ))
        to_connect_with_wifi $placa
        cnn=$RETf
        if [[ "$cnn" -eq "1" ]] ; then
            ciclos_de_espera=6
        else
            ciclos_de_espera=3
        fi
    fi

    if [[ ! -z "$MOTIVO" ]] ; then
        echo  "${MOTIVO}"
        MOTIVO=""
        nmcli device wifi list
    fi

    for i in {0..$ciclos_de_espera}; do
        trap SAI_n=1 SIGHUP SIGINT SIGTERM
        if [ 1 -eq $SAI_n ]; then
            echo -e "${COLOR_RED}saindo.${COLOR_RESET}"
            sleep 3
            break
        else
            if [[ 6 -eq $ciclos_de_espera ]]; then
                sleep 11
            else
                sleep 0.1
            fi
        fi
    done

done

echo -e "Fim monitoramento da conexão wifi${COLOR_RESET}"
