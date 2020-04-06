# certbot_lambda terraform

Deploy certbot_lambda with terraform. For each domain you want to configure this for, you'll need to deploy another instance of this script. Update the `vars_example.tf` file to accomodate that. 

This [repo](https://github.com/robertpeteuil/terraform-aws-certbot-cloudflare-lambda) is a great example of using lambda to update cloudflare hosted zones certificates. I don't have most of the requirements driving this, so I'm going to simplify a lot of what they did for this purpose.

## Requirements
- Create an S3 bucket for certificate storage. Don't make it publicly available.
- Create a user with rights to deploy this tool, an example permissions script is included.
- Configure your temporary key and secret key for access. 
- Terraform plan and apply. 

