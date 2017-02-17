#!/bin/sh

cd /home/cloak/pki

/home/cloak/bin/cloak-server crls \
    --out crls \
    --post-hook "cat crls/*.pem > new-crls.pem; mv new-crls.pem crls.pem; sudo ipsec rereadcrls"
