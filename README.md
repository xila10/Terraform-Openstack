# Terraform-Openstack
An overview and description of the code ran in Terraform to create a working infrastructure in a cloudenvironment, made possible by Openstack. 
# How Terraform Connects to Openstack:
We install Terraform on a local Virtual Machine, this will serve as out configuraiton platform. The instructions to install terraform are available on Hashicorp Cloud Platform https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli. To connect our VM to our cloud environment, we download the openrc.sh file available after login.
# OpenRC.sh file
An OpenRC file (openrc.sh) contains environment variable export commands used to authenticate to an OpenStack environment via the CLI.

It typically includes:
- username (OS_USERNAME)
- project/tenant name (OS_PROJECT_NAME)
- authentication URL (OS_AUTH_URL)
- region (OS_REGION_NAME)
- API version variables

**Purpose:** When you source openrc.sh, these variables are loaded into your shell so you can execute OpenStack CLI commands (like openstack server list) without manually entering authentication details each time.
# Regarding connectivity and authorization: 
Resource access, project ID, region, log in credentials and more, as mentioned, are sourced from the local virtual machine we run Terraform on, through the openrc.sh file. We reach the environment on (in this case) a Wireguard VPN which is setup based on a config file containing; ip address, private- and publickey, Endpoint and more. This establishes a connection between our network and the hosted network on which we reach the Openstack environment.

# Locals and providers: 
The locals block defines reusable values inside the Terraform configuration. Instead of repeating image IDs or the floating IP network name multiple times, we store them once and reference them where needed.  

![Screenshot](https://github.com/xila10/Terraform-Openstack/blob/main/images/screenshots/Sk%C3%A4rmbild%202026-03-11%20104629.png?raw=true)

The terraform block defines which provider Terraform must use. In this case, it specifies the OpenStack provider and where Terraform should download it from. This ensures the correct plugin is installed when running terraform init. The provider block tells Terraform how to connect to the cloud environment. Here it is empty because authentication details come from environment variables loaded via the openrc.sh file. Without a provider block, Terraform would not know where to create the infrastructure. 

The Openstack provider and where Terraform should download it from. 

![Screenshot](https://github.com/xila10/Terraform-Openstack/blob/main/images/screenshots/Sk%C3%A4rmbild%202026-03-11%20104641.png?raw=true)

Sources variables from openrc.sh file. 

# Terraform code: 
In this section we cover the code in Terraform and how it works; how it creates resources and an overview of what it consists of. The code in the project covers the following: 

- Networks 
- Compute 
- Routers 
- Security groups 
- Locals and provider 
- SSH-keys

# Infrastructure: 
These categories create the necessary resources needed for my cloud environment to work as intended. The environment is focused around running and accessing an application with access to it only through another instance that acts as a bastion; the traffic is managed to allow for this through security groups. An external network (connected to the router) gives access to the bastion through its public IP address (floating IP), the instances are connected to internal networks with their respective subnets; creating an environment accessible from the outside but governed by the rules set inside of the cloud. 

# SSH: 
Through SSH I can connect from my local computer to the internal instance running the application (no floating IP) through the bastion, using a shell of my choice to do so. I have set up a config file instructing the SSH-server to connect to the instances using the information provided: IP addresses, users and path to ssh-key. I also have instructed to use Proxy Jump; the instructions are understood by the SSH-client as “connect to internal instance through the Bastion instance; using the credentials provided”. 

The structure of the config file is according to standards and syntax and provides easier and cleaner connectivity; absolving the user of the need to write long commands. 
