resource "openstack_compute_instance_v2" "Cobra" {
  name            = "Cobra"
  flavor_name       = "m1.xlarge"
  key_pair        = openstack_compute_keypair_v2.labb_key.name
  security_groups = [openstack_networking_secgroup_v2.cobra_sg.name]

  block_device {
    uuid                  = local.ubuntu_2404_id
    source_type           = "image"
    volume_size           = 30
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    uuid = openstack_networking_network_v2.labnet-1.id
  }
}

resource "openstack_compute_instance_v2" "Bastion" {
  name            = "Bastion"
  flavor_name       = "m1.small"
  key_pair        = openstack_compute_keypair_v2.labb_key.name
  security_groups = [openstack_networking_secgroup_v2.bastion_sg.name] 

  block_device {
    uuid                  = local.ubuntu_2404_id
    source_type           = "image"
    volume_size           = 10
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    uuid = openstack_networking_network_v2.labnet-2.id
  }
}

# Allocating floating ip from pool:

resource "openstack_networking_floatingip_v2" "Bastion_fip" {
  pool = local.float_ip_pool  
}

# Retrieve the network port attached to the Bastion instance:

data "openstack_networking_port_v2" "Bastion_port" {
  device_id = openstack_compute_instance_v2.Bastion.id
}

# Associate floating ip with instance:

resource "openstack_networking_floatingip_associate_v2" "Bastion_fip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.Bastion_fip.address
  port_id     = data.openstack_networking_port_v2.Bastion_port.id
}

# --------------------------------------------------------
# Output for script (ssh conffig):

output "bastion_ip" {
  value = openstack_networking_floatingip_v2.Bastion_fip.address
}

output "cobra_ip" {
  value = openstack_compute_instance_v2.Cobra.network[0].fixed_ip_v4
}

#---------------------------------------------------
#'network' - "list of network objects".
# [0] first index 'network' (only 1 network attached)
# "terraform state show openstack_compute_instance_v2.Cobra"
# --> returns list of networkinterfaces.
# .fixed_ip_v4 --> returns ipv4 address from list.
