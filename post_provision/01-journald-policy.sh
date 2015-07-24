#!/bin/bash 

# Set static journald log retention policy
#sudo sed -i.bak  's/#SystemMaxUse=/SystemMaxUse=200M/' /etc/systemd/journald.conf && sudo systemctl restart systemd-journald
