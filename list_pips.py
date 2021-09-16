#!/usr/bin/env python3
import subprocess
import os

# packages installed for Python (PIP)
# pip list

cmd_01 = "pip list | awk '{ print $1 }' | awk 'NR>2' "
ret_01=os.popen(cmd_01).readlines()

arq = open("pi_pkgs.txt","w")

for linha in ret_01:
	arq.write (linha)

arq.close()
