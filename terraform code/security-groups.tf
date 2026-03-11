# ------------------------------------------------------------------

#Creating group for Bastion:
resource "openstack_networking_secgroup_v2" "bastion_sg" {
  name = "bastion_sg"
}

#Creatingg group for Cobra(NextCloud):
resource "openstack_networking_secgroup_v2" "cobra_sg" {
  name = "cobra_sg"
}

#-------------------------------------------------------------------

# COBRA RULES:

# Allowing SSH only from Bastion:

resource "openstack_networking_secgroup_rule_v2" "ssh_from_bastion" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_group_id   = openstack_networking_secgroup_v2.bastion_sg.id
  security_group_id = openstack_networking_secgroup_v2.cobra_sg.id
}

# HTTP for Nextcloud users
resource "openstack_networking_secgroup_rule_v2" "http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.cobra_sg.id
}

# HTTPS for Nextcloud users
resource "openstack_networking_secgroup_rule_v2" "https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.cobra_sg.id
}

#-------------------------------------------------------------------------

# BASTION RULES:

# Ingress SSH:
resource "openstack_networking_secgroup_rule_v2" "ssh_to_bastion_from_local" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.bastion_sg.id
}





