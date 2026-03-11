terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"  
    }
  }
}

provider "openstack" {   
}

#------------------------------------------------------------------------------------------
# terraform { } "meta block" describes what the configuration need to run; what "provider".

# provider - is a kind of binary file (plugin) containing the logic about Openstack and its resources.

# 'terraform init' - reads required providers, downloads binaries (logic).

# 'provider "openstack"' - here providing necessary credentials/variables to auth. against openstack env.

# This: resource "openstack_networking_router_v2" "r1" -> would not make sence without a provider.
#-------------------------------------------------------------------------------------------



