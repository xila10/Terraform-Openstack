#!/bin/bash

# Gets only IP from Terraform outputs:
BASTION_IP=$(terraform output -raw bastion_ip)
COBRA_IP=$(terraform output -raw cobra_ip)

# Writes to SSH config for Bastion and Cobra
cat > ~/.ssh/config <<EOF
Host Bastion
  HostName ${BASTION_IP}
  User ubuntu
  IdentityFile ~/.ssh/labb_key

Host Cobra
  HostName ${COBRA_IP}
  User ubuntu
  IdentityFile ~/.ssh/labb_key
  ProxyJump Bastion
EOF

echo "SSH config updated successfully!"

# -----------------------------------------------
# BASTION_IP=$(terraform output -raw bastion_ip):
# -----------------------------------------------
# -> Creates variabel "BASTION_IP"
# -> $(..) runs the command
# -----------------------------------------------
# terraform output -raw bastion_ip:
# -----------------------------------------------
# -> "terraform output" ; a terraform command.
# -> "-raw" ; no formating (only the IP in this case)
# -> "bastion_ip" ; named Terraform resource ; contains IP-address of the bastion instance.
# -----------------------------------------------
# SSH configfile format:
# -----------------------------------------------
# Host Bastion
#  HostName ${BASTION_IP}       -> The value of BASTION_IP is placed here.
#  User ubuntu                  -> Which user to use.
#  IdentityFile ~/.ssh/labb_key -> path to keypair (private)
# -----------------------------------------------
# "ProxyJump Bastion" -> Tells SSH to connect to Cobra through Bastion. 
# -----------------------------------------------
# "EOF" -> "End of file"
# -----------------------------------------------
# "<<EOF" -> "All text after this row shall be sent in to the command until EOF again."
# -----------------------------------------------
# Everything between <<EOF and the closing EOF is written directly into the SSH config file.
# cat > ~/.ssh/config <<EOF uses a heredoc to write multiple lines into a file.
# cat > ~/.ssh/config -> Writes output to the file ~/.ssh/config (overwrites it).
