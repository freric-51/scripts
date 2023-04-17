#!/usr/bin/env bash

sudo service avahi-daemon stop
sudo service cups-browsed stop
sudo /etc/init.d/cups stop
sleep 3
sudo service avahi-daemon start
sudo /etc/init.d/cups start
sudo /etc/init.d/cups-browsed start
sleep 6
ps aux | grep -i cups
