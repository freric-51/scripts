#!/usr/bin/env bash

# sudo apt install iputils-arping ifupdown ifupdown-extra

function find_device {
	cd "/sys/class/net/"
	ls -d wl*
}

function connected {
	#V=``
	# echo $V

	V=`cat /sys/class/net/$placa/carrier`
	echo $V
	return $?
}

function set_wifi_network {
	sudo ifconfig $placa down
	# sudo iw reg set GY
	sleep 2
	sudo ifconfig $placa up
	sleep 2
	sudo iwconfig $placa txpower 30
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

exit

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
	sleep 3
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
