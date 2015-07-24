#!/bin/bash 

cd /var/lib/apps/post_provision

# Reboot strategy
if [ -f etc/coreos/update.conf ];
then
    cp etc/coreos/update.conf /etc/coreos/update.conf
fi

for i in etc/systemd/system/*
do
    unit=$(basename $i)
    cp $i /$i
    sudo systemctl daemon-reload
    sudo systemctl reload-or-restart $unit
done
