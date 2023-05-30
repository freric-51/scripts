#!/usr/bin/env bash
# enp2s0 wlp2s0

DEVS=`cat /proc/net/dev | grep : | cut -d":" -f1 | tr -d " "`

for DEVICE in $DEVS ; do
	echo -e "Searching devices through network from device $DEVICE ..."
	sudo arp-scan --interface=$DEVICE --localnet --retry=10 --plain --ignoredups >> DevicesInMyNet.txt
done

sort -u -k2 DevicesInMyNet.txt -o u_DevInMyNet.txt
sed -i '/^$/d' u_DevInMyNet.txt
mv u_DevInMyNet.txt --force DevicesInMyNet.txt
cat DevicesInMyNet.txt
