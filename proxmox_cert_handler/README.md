
# Supporting SSL for Proxmox Gui's

I wanted something to handle HTTPS for my proxmox nodes. This does that.

## Python Script

This script is intended to run a cron job. It will download certs from your S3 bucket, update the certs on your system, restart the necessary services, and push an SNS notification that it did it's job.

## Configuring the script

Copy the script to your proxmox host and configure a cronjob to run as root. I run the script every tuesday and saturday. You can use the ansible playbook to set this up. 


## Manually

You could manaully recreate the work in this python script by doing these command line arguments. 

~~~
aws s3 cp s3://<bucket>/<prefix>/<domain>/privkey.pem ./
aws s3 cp s3://<bucket>/<prefix>/<domain>/fullchain.pem ./
aws s3 cp s3://<bucket>/<prefix>/<domain>/chain.pem ./
mv privkey.pem /etc/pve/local/pve-ssl.key
mv chain.pem /etc/pve/pve-root-ca.pem
mv fullchain.pem /etc/pve/local/pve-ssl.pem
service pveproxy restart
service pvedaemon restart
~~~

