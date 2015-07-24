#!/bin/bash

# If etcd is active, this uses locksmith. Otherwise, it randomly delays the reboot. 
delay=$(/usr/bin/expr $RANDOM % 3600 )
rebootflag='NEED_REBOOT'

if update_engine_client -status | grep $rebootflag;
then
    echo -n "etcd is "
    if systemctl is-active etcd;
    then
        echo "Update reboot with locksmithctl."
        locksmithctl reboot
    else
        echo "Update reboot in $delay seconds."
        sleep $delay
        reboot
    fi
fi
exit 0
