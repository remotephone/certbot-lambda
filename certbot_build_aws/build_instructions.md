***DEPRECATED***

You can use these series of commands to create your environment and when its done, you'll find the file just waiting in your s3 bucket. 

~~
aws s3 mb s3://my-certbot-bucket-its-a-secret --region us-east-2  
aws iam create-role --role-name certbots3putrole-ec2-profile --assume-role-policy-document file://certbots3-trust.json  
aws iam put-role-policy --role-name certbots3putrole-ec2-profile --policy-name certbots3put-policy --policy-document file://certbots3-permissions.json  
aws iam create-instance-profile --instance-profile-name certbots3putrole-ec2-profile  
aws iam add-role-to-instance-profile --instance-profile-name certbots3putrole-ec2-profile --role-name certbots3putrole-ec2-profile  
aws ec2 run-instances --image-id ami-ea87a78f --instance-type t2.micro --count 1 --user-data file://build.txt --iam-instance-profile Name=certbots3putrole-ec2-profile --region us-east-2 --key-name my-ec2-key   
~~~
