#!/usr/bin/env bash

if [ -e /etc/init.d/networking ]; then
	echo "restart networking"
	sudo /etc/init.d/networking restart
else
	if [ -e /etc/init.d/network-manager ]; then
		echo "restart network-manager"
		sudo /etc/init.d/network-manager force-reload
		sleep 3
		sudo /etc/init.d/network-manager restart
	fi
fi
