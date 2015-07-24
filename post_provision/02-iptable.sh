#!/bin/bash 

# Install iptables to block outbound calls from containers - EC2 metadata, etcd client and server ports are blocked.
#sudo iptables -I FORWARD 1 -i docker0 -p tcp -m tcp --dport 7001  -j DROP
#sudo iptables -I FORWARD 1 -i docker0 -p tcp -m tcp --dport 4001  -j DROP
#sudo iptables -I FORWARD 1 -i docker0 -d 169.254.169.254/32 -j DROP
