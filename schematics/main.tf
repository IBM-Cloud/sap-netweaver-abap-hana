module "pre-init" {
  source		= "./modules/pre-init"
}

module "precheck-ssh-exec" {
  source		= "./modules/precheck-ssh-exec"
  depends_on	= [ module.pre-init ]
  BASTION_FLOATING_IP = var.BASTION_FLOATING_IP
  private_ssh_key = var.private_ssh_key
  HOSTNAME		= var.DB-HOSTNAME
  SECURITY_GROUP = var.SECURITY_GROUP
}

module "vpc-subnet" {
  source		= "./modules/vpc/subnet"
  depends_on	= [ module.precheck-ssh-exec ]
  ZONE			= var.ZONE
  VPC			= var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  SUBNET		= var.SUBNET
}

module "db-vsi" {
  source		= "./modules/db-vsi"
   depends_on	= [ module.vpc-subnet ]
  ZONE			= var.ZONE
  VPC			= var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  SUBNET		= var.SUBNET
  RESOURCE_GROUP = var.RESOURCE_GROUP
  HOSTNAME		= var.DB-HOSTNAME
  PROFILE		= var.DB-PROFILE
  IMAGE			= var.DB-IMAGE
  SSH_KEYS		= var.SSH_KEYS
  VOLUME_SIZES	= [ "500" , "500" , "500" ]
  VOL_PROFILE	= "10iops-tier"

}

module "app-vsi" {
  source		= "./modules/app-vsi"
  depends_on	= [ module.vpc-subnet ]
  ZONE			= var.ZONE
  VPC			= var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  SUBNET		= var.SUBNET
  RESOURCE_GROUP = var.RESOURCE_GROUP
  HOSTNAME		= var.APP-HOSTNAME
  PROFILE		= var.APP-PROFILE
  IMAGE			= var.APP-IMAGE
  SSH_KEYS		= var.SSH_KEYS
  VOLUME_SIZES	= [ "40" , "128" ]
  VOL_PROFILE	= "10iops-tier"

}

module "ansible-deployment" {
  source		= "./modules/ansible-exec"
  depends_on	= [ module.db-vsi , module.app-vsi , local_file.ansible_inventory , local_file.db_ansible_saphana-vars , local_file.app_ansible_nwapp-vars ]
  IP			= data.ibm_is_instance.app-vsi-1.primary_network_interface[0].primary_ip[0].address
  PLAYBOOK = "playbook.yml"
  BASTION_FLOATING_IP = var.BASTION_FLOATING_IP
  private_ssh_key = var.private_ssh_key
}