# Challenge 3: Website Deployment

Welcome to Challenge 3.

This project was bootstrapped with [Create Next App](https://github.com/segmentio/create-next-app).

## Task 1

Given this project deploy it to AWS in an automated and reproducible fashion. The website should be reachable from all over the world.
 >> Follow the instruction in the Getting started section

## Task 2

Restrict access to the site by using mechanisms that can be adapted programmatically.
>> Description in Access Management Section

## Task 3

Deploy the site using at least 2 technology stacks. Make sure that both types of deployment can be reproduced in an automated fashion.

>> More details provided in the Getting started section

## Task 4

What issues can you identify in the given site? What types of improvements would you suggest?

>> Test cases missing : Would advice to have a test based development with a unit and integration setup that should be made mandatory to be executed in the deployment pipeline. Failure to pass any test cases should reject the deployment.
>> To many duplicate CSS styling and javascript : This impacts the performance and page loading time.
>> Minify css and javascript : This is the solution to the previous comment, minification removes unnecessary characters and reduces time, hence improving loading time.
>> Proper error handling is missing : As a more robust DevSecOps solution and proper logging, alerting and mechanism should be in place for a proactive error/incident management. 


## GETTING STARTED

## Automate Infra Provisioning and hosting static website

#### Application Stack - Solution 1
    ○ Load Balancer
    ○ 3 Web Servers (EC2)
        ■ Docker app:
            nextjs-nodenpm
#### Application Stack - Solution 2
    ○ Application Load Balancer
    ○ Elastic Container Service
    ○ Elastic Container Registry
        ■ Docker image

### Application Stack - Endless posibilities
    ○ Serverless Frmaework
    ○ Lambda
    ○ Elasticbeanstalk

#### Tech/framework used
- AWS CLI
- Terraform
- Docker
- Ansible
        

### Pre-requisites
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)


## Execution steps

- To build the stack : 
    `ansible-playbook ansible/cicd.yml`

- To destroy : 
    `ansible-playbook ansible/destroy.yml`

## Expected results 

Applying this Terraform configuration returns the load balancer's public URL on the last line of output.  This URL can be used to view the default webapplication website page. Also, the ouput provids rds address. So, the output should look like this:

url = http://docker-test-devops-alb-685434547.eu-central-1.elb.amazonaws.com/

## FAQ's/Tips

### Access Management
IAM roles are specified in the policies folder and a dedicated profile with the required roles are created programmitically, in case of any update the json files within the 'policies' folder can be updated and redeployed. 
End users can be manually , automatically or programmitically be assigned the role to be able to gain access to the site. 

### EC2 Keypair 
The EC2 keypair name and ey gets generated automatically within the code. However if you wish to use your own generated key you can make modification (In var.tf-> Uncomment line24 & In ec2.tf-> Uncomment #16 & Comment #17)

However, this is not a recommened practice. For a more secured setting, the key should be generated manually so that the private key can be shared with the required users for a local Open SSH connection.

### AWS user and secret key
Please make sure your terraform , aws cli and ansible has the aws_access_key and aws_secret_key setup. If it is not setup, uncomment the section in var.tf and provider.tf and provide the key as default value.

