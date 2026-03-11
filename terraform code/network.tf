
#Creating networks and subnet 1 & 2:
resource "openstack_networking_network_v2" "labnet-1" {
  name = "labnet-1"
}

resource "openstack_networking_subnet_v2" "labsub-1" {
  name            = "labsub-1"
  network_id      = openstack_networking_network_v2.labnet-1.id
  cidr            = "192.168.1.0/24"
  dns_nameservers = ["1.1.1.1", "8.8.8.8"]
  ip_version      = 4
}

resource "openstack_networking_network_v2" "labnet-2" {
  name = "labnet-2"
}

resource "openstack_networking_subnet_v2" "labsub-2" {
  name            = "labsub-2"
  network_id      = openstack_networking_network_v2.labnet-2.id
  cidr            = "192.168.2.0/24"
  dns_nameservers = ["1.1.1.1", "8.8.8.8"]
  ip_version      = 4
}

# Gathering information about already existing resource external-net:

data "openstack_networking_network_v2" "ext-net" {
  name = "external-net"  
}

# Creating router, linking and namning it to external network: 
resource "openstack_networking_router_v2" "rtr-1" {
  name                = "rtr-1"
  external_network_id = data.openstack_networking_network_v2.ext-net.id
}

# Creating interfaces (using rtr-1) and linking subnets:

resource "openstack_networking_router_interface_v2" "rtr-int1" {
  router_id = openstack_networking_router_v2.rtr-1.id
  subnet_id = openstack_networking_subnet_v2.labsub-1.id
}

resource "openstack_networking_router_interface_v2" "rtr-int2" {
  router_id = openstack_networking_router_v2.rtr-1.id
  subnet_id = openstack_networking_subnet_v2.labsub-2.id
}





