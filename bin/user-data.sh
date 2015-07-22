#!/usr/bin/bash
# This script gets excecuted on each reboot. It can be an additional config you want to set after CoreOS's cloud-config.
cloudconfig='/var/lib/apps/cloud-config'
if [ -d $cloudconfig ]
then
    for i in $cloudconfig/*.sh
    do
      /bin/bash -x $i
    done
fi
