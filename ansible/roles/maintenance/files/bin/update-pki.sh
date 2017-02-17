#!/bin/sh

/home/cloak/bin/cloak-server pki \
    --out /home/cloak/pki \
    --post-hook "sudo service openvpn restart; sudo ipsec reload"
