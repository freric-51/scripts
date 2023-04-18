#!/usr/bin/env bash

# sudo apt install iputils-arping ifupdown ifupdown-extra

function find_device {
	cd "/sys/class/net/"
	ls -d wl*
}

function connected {
    V=`iw $placa link`
    #echo $V
    if [ $V eq "Not connected."]; then
        V=0
    else
        V=1
    if
	return $?

    # tentativa errada, o link fisico está ON independente da conexão.
    # V=`cat /sys/class/net/$placa/carrier`

    # tentativa errada, "Not connected." mesmo tendo ping
    # V=`iw $placa link`
    #echo $V
    # "Not connected."

}

function set_wifi_network {
	sudo ifconfig $placa down
	# sudo iw reg set GY
	sleep 2
	sudo ifconfig $placa up
	sleep 2
	sudo iwconfig $placa txpower on
	# iw reg get
	sleep 1
	return 2
}

placa=`find_device`

echo -e "configuracao wifi de $placa.\n"
cnn=`connected`
echo $cnn
cnn=`set_wifi_network`
echo $cnn

SAI_n=2
while [ 1 -ne $SAI_n ]; do
	cnn=`connected`

	if [ $cnn -eq "1" ]; then
		echo -e "$cnn online"
		exit
	else
		echo -e "$cnn offline"
	fi

	sudo sleep 0.1
	echo -e "stopping wifi ...\n"
	sudo service network-manager stop
	sleep 5
	echo -e "starting wifi ...\n"
	sudo service network-manager start
	sleep 90

	cnn=`connected`

	if [ $cnn -eq "1" ]; then
		echo -e "$cnn online"
		exit
	else
		echo -e "$cnn offline"
	fi

	echo -e "reloading wifi ...\n"
	sudo service network-manager reload

	trap $SAI_n=1 SIGHUP SIGINT SIGTERM
	if [ 1 -ne $SAI_n ]; then
		sleep 120
	fi
done

exit





# # sudo ifdown $placa
# # sleep 3
# # sudo ifup -v $placa
# # sleep 3

# #sudo iwconfig $placa retry 7  # Retry short limit:7 4F=max
# #sudo iwconfig $placa rts 2347 # RTS thr=2347
# #sudo iwconfig $placa frag off # Fragment thr:off

# sudo iwconfig $placa retry min limit 31
# sudo iwconfig $placa rts 7168
# sudo iwconfig $placa frag 512

# sudo iwconfig $placa essid on
# sudo iwconfig $placa channel auto
# sudo iwconfig $placa rate 11M
# sudo iwconfig $placa txpower auto

# #sudo iwconfig $placa modu 11b

# echo -e "\n"
# iwconfig
