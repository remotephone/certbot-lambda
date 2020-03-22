# certbot-lambda

Running Certbot on AWS Lambda.

Leaning heavily on [Deploying EFF's Certbot in AWS Lambda](https://arkadiyt.com/2018/01/26/deploying-effs-certbot-in-aws-lambda/).

## Features

- Supports wildcard certificates (Let's Encrypt ACME v2).
- Uploads certificates to specified Amazon S3 bucket.
- Works with CloudWatch Scheduled Events for certificate renewal.

## Sample Event

If you want to configure a test event for the lambda function, it should look something like this:

```json
{
    "domains": "foobar.com",
    "email": "[EMAIL]",
    "s3_bucket": "[BUCKET]",
    "s3_prefix": "[KEY_PREFIX]"
}
```

## Changes from fork
I created the build.txt and build_instructions to simplify the build and ensure this is documented somewhere other than a blog that I might not be able to find later. I've also included sample permissions and trust documents. The permissions will need to be modified to suit your environment.

I have also included a terraform script to deploy this. Yay.

## Instructions

You will need:

- A hosted zone in AWS
- An S3 bucket you control
- an IAM user that can deploy all this stuff (I'm using an admin account protected by MFA described [here](https://remotephone.github.io/lab/homelab/aws/cloud/workflow/2020/01/21/My-AWS-Organization.html))
- Built certbot using the instructions below

You will have certificates dropped in an s3 bucket for retrieval when you need them. If you're using proxmox, the proxmox_cert_handler pulls them every time they're updated and restarts services for you. To set that up, you'll need to provide credentials to you proxmox servers to pull the required certs. 

If you want to do this for multiple domains you need to deploy multiple copies of the lambda function.

### certbot_build

Theres two folders to build this. One is the deprecated aws mode, launch an ec2 instance, get it built, add all the bits, and then it'll copy the done zip to an s3 bucket (look for the bits you need to modify to make this work). You'll also need to manually add the main.py file to it. I'm leaving it for context. 

Nowadays, you can run build and run the docker file. It will exit and leave the file in a directory in temp.

~~~
docker build -t cerbot .
mkdir /tmp/certbot
docker run -it -v /tmp/certbot:/root certbot
~~~