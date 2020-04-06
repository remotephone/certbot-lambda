import argparse
import hashlib
import logging
from logging.handlers import RotatingFileHandler
from logging import handlers
import os
import shutil
import subprocess
import sys
import pathlib
import glob

import boto3
import botocore

## Works for Proxmox 5.2 and 6.x.
# Assumes you've configured you key and secret key in your aws credentials file

# References
## https://boto3.amazonaws.com/v1/documentation/api/latest/guide/s3-example-download-file.html
## https://blog.hostonnet.com/install-letsencrypt-ssl-proxmox


logging.basicConfig(
    filename="certbot.log", level=logging.INFO, format="%(asctime)s %(message)s"
)
logger = logging.getLogger()


def get_certs(bucket):

    with open("/etc/hostname", "r") as f:
        node = f.read().rstrip("\n")

    files = {
        "fullchain.pem": "pve-ssl.pem",
        "privkey.pem": "pve-ssl.key",
        "chain.pem": "pve-root-ca.pem",
    }

    domain = "<your_domain>"
    pathlib.Path("/tmp/" + node).mkdir(parents=True, exist_ok=True)
    s3 = boto3.resource("s3")
    new_files = []
    for rem, local in files.items():
        remote = "certs/" + node + "." + domain + "/" + rem
        local = "/tmp/" + node + "/" + local
        try:
            s3.Bucket(bucket).download_file(remote, local)
            new_files.append(local)
        except botocore.exceptions.ClientError as e:
            if e.response["Error"]["Code"] == "404":
                logger.info("The object does not exist.")
            else:
                raise
    logger.info(new_files)
    return new_files


def check_certs(files):
    hashes = []
    for file in files:
        hasher = hashlib.md5()
        with open(file, "rb") as afile:
            buf = afile.read(128)
            while len(buf) > 0:
                hasher.update(buf)
                buf = afile.read(128)
        hashes.append(hasher.hexdigest())
    return hashes


def update_certs(files):
    logger.info("[-] Everything checks out! Time to update certs")
    for file in files:
        try:
            logger.info("trying {}".format(file))
            if file.endswith("pve-ssl.key"):
                logger.info("Copying {}".format(file))
                shutil.copyfile(file, "/etc/pve/local/pve-ssl.key")
                os.chmod("/etc/pve/local/pve-ssl.key", 0o640)
            elif file.endswith("pve-root-ca.pem"):
                logger.info("Copying {}".format(file))
                shutil.copyfile(file, "/etc/pve/pve-root-ca.pem")
                os.chmod("/etc/pve/pve-root-ca.pem", 0o640)
            elif file.endswith("pve-ssl.pem"):
                logger.info("Copying {}".format(file))
                shutil.copyfile(file, "/etc/pve/local/pve-ssl.pem")
                os.chmod("/etc/pve/local/pve-ssl.pem", 0o640)
        except OSError:
            logger.info("unable to copy files, exiting")
            raise SystemExit
    logger.info("[-] copying successful, restarting processes")
    subprocess.call("/usr/sbin/service pveproxy restart", shell=True)
    subprocess.call("/usr/sbin/service  pvedaemon restart", shell=True)
    logger.info("[-] Services Restarted, exiting")

    logger.info("[-] cleaning up cert files")
    files = glob.glob("/tmp/pve1/*")
    for f in files:
        os.remove(f)

    raise SystemExit


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-b", "--bucket", help="S3 bucket name where the certs live")
    args = parser.parse_args()
    bucket = args.bucket
    # Check only the SSL Key to see if it's changed
    old_files = ["/etc/pve/local/pve-ssl.key"]

    new_files = get_certs(bucket)
    new_hashes = check_certs(new_files)
    try:
        now_hashes = check_certs(old_files)
    except FileNotFoundError:
        now_hashes = []

    counter = 0
    for hash in new_hashes:
        if hash in now_hashes:
            counter += 1
        else:
            pass
    if counter >= 1:
        logger.info("[!] hashes match, nothing to do")
        raise SystemExit
    else:
        logger.info("[-] All is well, no hashes exist")
        update_certs(new_files)


if __name__ == "__main__":
    main()
