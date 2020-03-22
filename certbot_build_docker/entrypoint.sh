#!/bin/bash
yum install -y wget tar gzip zip make gcc python3 python3-pip zlib zlib-devel openssl openssl-devel

cd /root
which pip3
pip3 install virtualenv
which virtualenv
virtualenv venv
cd venv
source bin/activate
python --version

# Install certbot and other needed dependencies
pip install certbot certbot-dns-route53 raven

# Zip it all up
cd /root/venv/lib/python3.7/site-packages
zip -r /root/certbot.zip .
cd /root/venv/lib64/python3.7/site-packages
zip -r /root/certbot.zip .
cd /tmp
zip -ru /root/certbot.zip main.py

echo "[!] All done! Check the temp directory you mounted for your zip!"