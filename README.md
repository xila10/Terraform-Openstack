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

**Configfile:** Here are the following configs for SSH connections: 

![Screenshot](https://github.com/xila10/Terraform-Openstack/blob/main/images/screenshots/Sk%C3%A4rmbild%202026-03-11%20104656.png?raw=true)

This config file has a need for updating however, every time Terraform creates the infrastructure anew a different IP address is chosen from the pool – this means a hard coded value will be outdated every time Terraform runs. I have solved this by running a bash script that updates the config file with new information.  

The script is run after a successful Terraform operation (terraform apply) and is as follows: 

![Screenshot](https://github.com/xila10/Terraform-Openstack/blob/main/images/screenshots/Sk%C3%A4rmbild%202026-03-11%20104705.png?raw=true)

The new IP address value is placed in each variable and used in the new SSH config file. The old file is overwritten, and the updated file is ready for usage. The command line “$(terraform output -raw bastion_ip)” is dependent on a piece of Terraform code named “bastion_ip”. It looks like this:

![Screenshot](https://github.com/xila10/Terraform-Openstack/blob/main/images/screenshots/Sk%C3%A4rmbild%202026-03-11%20104714.png?raw=true)

A similar piece of code exists for the internal instance “Cobra” as well; pulling its assigned ip address. The code above instructs Terraform to create an output of the floating ip resource type associated with “Bastion_fip”; another piece of code that creates the floating ip from the available pool. More about this and the workings of Terraform code later.

# The Terraform statefile: 
Terraform uses a state file “terraform.tfstate” to keep track of the infrastructure it manages. The state maps cloudresources to the resource blocks defined in the Terraform configuration files. This allows Terraform to know what already exists and what needs to be created, updated, or deleted.    
Before making any changes, Terraform refreshes the state to compare the actual infrastructure with the configuration (when using ex. terraform plan/apply). Without this, Terraform would not function properly, and it is therefore not advised to manipulate the state file without full insight of what you are doing.

# The inner workings of Terraform: 
Coming up are examples of how Terraform works – the usage of different resource types that create resource blocks; containing attributes with values. You name the blocks and refer to the code inside through the name that is given. By doing this, we instruct Terraform to link resources and structures together to form associations and “tie it all together”. 

It is the same when creating networks, subnets, routers and instances – each with their unique resource types and attributes. Terraform operates by reading through the resource blocks and structures the order of creation by dependencies between the blocks: (3) Bastion_fip_associate → (2) Bastion_port → (1) Bastion-instance – as well as creating in parallel what can be. The nature of Terraform is therefore declarative rather than imperative – we specify what we want, use the correct structures – and Terraform takes care of the creation process as well as the order of it. 

# Creating and allocating floating ip:
Terraform creates a floating ip address from the available pool: 

![Screenshot](https://github.com/xila10/Terraform-Openstack/blob/main/images/screenshots/Sk%C3%A4rmbild%202026-03-11%20104723.png?raw=true)

The name “Bastion_fip” is representative of this code block within Terraform. 

We pull data related to the port on which the instance is: 

![Screenshot](https://github.com/xila10/Terraform-Openstack/blob/main/images/screenshots/Sk%C3%A4rmbild%202026-03-11%20104732.png?raw=true)

The data source is a Terraform block type that pulls information from already existing resources. So, the above mean; “retrieve the network port attached to the instance with the given device_id”.  

We specify resource type “openstack_...port_v2”, assigning a value in the “device_id” attribute where we refer to the resource block for “instance”; the instance being “Bastion” which is a named block with its own specifics in the compute.tf file. 

Lastly, we create a resource containing the allocated floating ip and the port connected to the instance we wish the ip to be assigned to: The data source is a Terraform block type that pulls information from already existing resources. So, the above mean; “retrieve the network port attached to the instance with the given device_id”.  

We specify resource type “openstack_...port_v2”, assigning a value in the “device_id” attribute where we refer to the resource block for “instance”; the instance being “Bastion” which is a named block with its own specifics in the compute.tf file. 

Lastly, we create a resource containing the allocated floating ip and the port connected to the instance we wish the ip to be assigned to: 

![Screenshot](https://github.com/xila10/Terraform-Openstack/blob/main/images/screenshots/Sk%C3%A4rmbild%202026-03-11%20104739.png?raw=true)

# Instances: 
An example of an instance in Terraform: 

![Screenshot](https://github.com/xila10/Terraform-Openstack/blob/main/images/screenshots/Sk%C3%A4rmbild%202026-03-11%20104748.png?raw=true)

Attributes provided describe what resources the instance will have access to, be connected to as well as name in the cloud etc. Security groups of which the instance is a member of (governs ingress/egress traffic) and keypairs to be included in the creation of the instance.  

We also have “block_device” which provides instructions for how the disc is to be created and linked. This is a nested block, meaning it is included in the “Bastion” block in this case. 

We can read that the data is coming from an “image”, the volume size will be “10” Gib and should the instance be deleted; also, the volume connected to it will be. Also, we have an entry for which network the instance will be connected to. Referred in the resource type above is “labnet-2”. 

# Networks: 

![Screenshot](https://github.com/xila10/Terraform-Openstack/blob/main/images/screenshots/Sk%C3%A4rmbild%202026-03-11%20104758.png?raw=true)

As the name suggests, this is a resource that creates a network named “labnet-2”. Underneath we have defined the subnet connected to the network – this is where all the details are provided relevant to a functioning network. 

Within “labsub-2" we have provided the attribute “network_id” that links it to the network “labnet-2” through the syntax as discussed before:  

(resource type) openstack_networking_network_v2  + (predefined resource block) labnet-2 + attribute-type. 

In this way, we integrate predefined resource blocks within new ones to link it all together. Through a similar process we set up our router, connecting it to our networks and linking it to the predefined external network already available through the cloud environment.

# External net: 

![Screenshot](https://github.com/xila10/Terraform-Openstack/blob/main/images/screenshots/Sk%C3%A4rmbild%202026-03-11%20104812.png?raw=true)

Using data source to pull existing data about the external-net. 

# Router setup: 

![Screenshot](https://github.com/xila10/Terraform-Openstack/blob/main/images/screenshots/Sk%C3%A4rmbild%202026-03-11%20104820.png?raw=true)

Resource type “openstack_networking_router_v2”, naming it ‘rtr-1’ in Terraform and in The Cloud. We give the router an external gateway → ‘ext-net’ to ‘rtr-1’. Observe, again we are using data source to pull on existing data since the network is not managed or configured by us. 

Here, creating the interfaces on to which we connect our subnets; using the “..._router_interface” resource type: 

![Screenshot](https://github.com/xila10/Terraform-Openstack/blob/main/images/screenshots/Sk%C3%A4rmbild%202026-03-11%20104827.png?raw=true)

One interface is named “rtr-int1” and refers to the router and the subnet; thus creating a connection between them. A port on the router is created, and the router receives an ip address in the subnet. 









