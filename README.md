# Terraform-Openstack
An overview and description of the code ran in Terraform to create a working infrastructure in a cloudenvironment, made possible by Openstack. 
# How Terraform Connects to Openstack:
We install Terraform on a local Virtual Machine, this will serve as out configuraiton platform. The instructions to install terraform are available on Hashicorp Cloud Platform https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli. To connect our VM to our cloud environment, we download the openrc.sh file available after login.
#OpenRC.sh file
An OpenRC file (openrc.sh) contains environment variable export commands used to authenticate to an OpenStack environment via the CLI.

It typically includes:
-username (OS_USERNAME)
-project/tenant name (OS_PROJECT_NAME)
-authentication URL (OS_AUTH_URL)
-region (OS_REGION_NAME)
-API version variables

Purpose:
When you run source openrc.sh, these variables are loaded into your shell so you can execute OpenStack CLI commands (like openstack server list) without manually entering authentication details each time.
#Regarding connectivity and authorization: 
Resource access, project ID, region, log in credentials and more, as mentioned, are sourced from the local virtual machine we run Terraform on, through the openrc.sh file. We reach the environment on (in this case) a Wireguard VPN which is setup based on a config file containing; ip address, private- and publickey, Endpoint and more. This establishes a connection between our network and the hosted network on which we reach the Openstack environment.
