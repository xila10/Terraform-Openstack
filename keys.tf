
# Provides Terraform with path to pub-key, includes it in the instances:

resource "openstack_compute_keypair_v2" "labb_key" {
  name       = "labb-key"
  public_key = file("${path.module}/keys/labb_key.pub")
}

# file -> 'built in Terraform function'.
# ${...} -> 'Put the value of this expression here'.
# path.module -> Terrafform variable = the catalogue where the .tf-files are.
# path.module + /keys/labb_key.pub = complete path
# module = in Terraform; a catalogue containing .tf-files.
# ~/cloud-labs/2-setup-infra-IaC/terraform -> is where my 'root-module' is. This is where 'terraform init' was done. 



