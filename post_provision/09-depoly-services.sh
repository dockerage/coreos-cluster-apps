#!/bin/bash
#
# Start core serivce if they are not running.

#services="jenkins registry"

function start_service {
    if [ ! -f /var/lib/apps/$1/units/$1.service ]
    then
        echo "/var/lib/apps/$1/units/$1.service does not exist"
        exit 0
    else
        fleetctl start /var/lib/apps/$1/units/$1.service
    fi
}

# Main
for i in $services
do
    fleetctl list-units | grep $i | grep -q running || start_service $i
done
