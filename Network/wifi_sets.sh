#!/usr/bin/env bash
# Freitas April 22 2023
# kernel  5.15.0-70-generic
# keep wifi working
# if it stops then off/on the radio to force reconnecting

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

    ESSID=`iwconfig $1 | grep -i ESSID | cut -d" " -f8 `
    if [ $ESSID == 'ESSID:off/any' ]; then
        # try to connect to first wifi ESSID
        RUN=`nmcli device set $1 autoconnect yes`
        RUN=`nmcli con show | grep wifi | cut -d" " -f1 | head -n 1 | xargs -I{}  nmcli con up id {}`
        sleep 20
        FUNCTIONAL=0
    else
        Quality=`iwconfig $1 | grep -i 'link quality' | awk '{ print $2 }' | cut -d"=" -f2 | cut -d"/" -f1`
        if [ $Quality -lt 20 ]; then
            FUNCTIONAL=0
        else
            # 1 pacotes transmitidos, 0 recebidos, 100% perda de pacote, tempo 0ms
            # 1 packets transmitted, 1 received, 0% packet loss, time 0ms
            # RECEbido ~ RECEived
            Received=`ping -c1 -q -W10 1.1.1.1 | sed -r '/^[\s\t]*$/d' | grep -i "rece" | cut -f2 -d, | cut -d" " -f2`
            if [ $Received -eq 0 ]; then FUNCTIONAL=0; else FUNCTIONAL=1; fi
        fi
    fi
    echo $FUNCTIONAL
}

# =======
#  MAIN
# =======

placa=$(find_device)
echo -e "Monitoração wifi de $placa"

SAI_n=999
while [ 1 -ne $SAI_n ]; do

	cnn=$(connected $placa)

	if [ $cnn -eq "1" ]; then
		echo -e "$cnn online - `date +%H:%M:%S`"
	else
		echo -e "$cnn offline - `date +%H:%M:%S`"
        sleep 0.1
        echo -e "\tstopping wifi ..."
        # sudo service network-manager stop
        nmcli radio wifi off
        sleep 5
        echo -e "\tstarting wifi ..."
        # sudo service network-manager start
        nmcli radio wifi on
	fi

	trap $SAI_n=1 SIGHUP SIGINT SIGTERM
	if [ 1 -eq $SAI_n ]; then
        echo "saindo."
	else
    	for i in {0..4}; do
            sleep 11
        done
	fi
done
