#!/usr/bin/env python3
import subprocess
import os

# Freitas Power ;)

# pip list --outdated
# pip install --user --upgrade xxx ; sleep 5 ; pip list --outdated

cmd_01 = "pip list --outdated | awk '{ print $1 }' | awk 'NR>2' "
ret_01=os.popen(cmd_01).readlines()
#	print("oi", ret )

for linha in ret_01:
	print (linha)

cmd_02 = "pip install --user --upgrade "
for linha in ret_01:
	print ('\n', cmd_02, linha),
	os.system(cmd_02 + linha)

