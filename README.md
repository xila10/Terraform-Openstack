# Terraform-Openstack
An overview and description of the code ran in Terraform to create a working infrastructure in a cloudenvironment, made possible by Openstack. 
# How Terraform Connects to OpenStack:
The instructions to install terraform are available online, but there are a few more steps
to connect it to our cloud environment.
We need openrc.sh which is a file containing environment variables for Openstack
regarding connectivity and authorization towards the Openstack environment –
resource access, project ID, region, log in credentials and more. We source this in the
local virtual machine we run Terraform on.
We reach the environment on Wireguard VPN which is setup based on a config file
containing ip address, private- and publickey, Endpoint and more. This connects us to
the Openstack environment hosted by the school.
