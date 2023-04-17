#!/usr/bin/env bash

DEVICE=wlp2s0

sudo arp-scan --interface=$DEVICE --localnet --retry=10 --plain --ignoredups >> DevicesInMyNet.txt
sort -u -k2 DevicesInMyNet.txt -o u_DevInMyNet.txt
sed -i '/^$/d' u_DevInMyNet.txt
mv u_DevInMyNet.txt --force DevicesInMyNet.txt
cat DevicesInMyNet.txt
