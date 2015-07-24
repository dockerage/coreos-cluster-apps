#!/bin/bash
# Make sure there is enough space on root. 
size=$(df -h / | tail -1 | awk '{print $2}')
size=${size/\.*/}
size=${size/G/}
if [ $size -gt 16 ]; 
then
    SWAPFILE=/swapfile
    if [ ! -f $SWAPFILE ];
    then
        # Add swap = mem * 2        
        mem=$(free -m | grep Mem | awk '{print $2}')
        dd if=/dev/zero of=$SWAPFILE bs=1M count=$mem && \
        mkswap $SWAPFILE && \
        chmod 600 $SWAPFILE 
    fi
    /sbin/swapon $SWAPFILE
fi
