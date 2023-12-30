#!/usr/bin/env bash

# DEVS=`cat /proc/net/dev | grep : | cut -d":" -f1 | tr -d " " | grep -v lo | grep  ^w`

# 2023 11 25 - list only connected network devices
DEVS=$(ip -oneline link show | grep -i -v no-carrier | awk -F': ' '{print $2}' | grep -v lo)

for DEVICE in $DEVS ; do
	echo -e "Searching devices through network from device $DEVICE ..."
	sudo arp-scan --interface=$DEVICE --localnet --retry=10 --plain --ignoredups -qg | awk '{print $1 "\t" $2}' >> DevicesInMyNet.txt
    # --timeout=500 --random
done

sudo arp -n | awk '{print $1 "\t" $3}' | tail --lines=+2 >> DevicesInMyNet.txt
sudo arp-scan --localnet | grep -i interface | sed -r 's/,/ /g' | awk '{print $8"\t"$6}' >> DevicesInMyNet.txt

sort -u -k2 DevicesInMyNet.txt -o u_DevInMyNet.txt
sed -i '/^$/d' u_DevInMyNet.txt
mv u_DevInMyNet.txt --force DevicesInMyNet.txt
cat DevicesInMyNet.txt

#sudo iwlist $DEVICE scanning
#  IE: IEEE 802.11i/WPA2 Version 1
#                         Group Cipher : CCMP
#                         Pairwise Ciphers (1) : CCMP
#                         Authentication Suites (1) : PSK

# sudo wpa_cli -i $DEVICE status

# sudo arp-scan --interface=$DEVICE --localnet