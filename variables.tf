############################################################
# The variables and data sources used in VPC infra Modules. 
############################################################

variable "ID_RSA_FILE_PATH" {
    default = "ansible/id_rsa"
    nullable = false
    description = "File path for PRIVATE_SSH_KEY which will be automatically generated. If it is changed, it must contain the relative path from git repo folders."
}

variable "PRIVATE_SSH_KEY" {
	type		= string
	description = "id_rsa private key content in OpenSSH format (Sensitive value). This private key should be used only during the terraform provisioning and it is recommended to be changed after the SAP deployment."
}

variable "SSH_KEYS" {
	type		= list(string)
	description = "List of SSH Keys UUIDs that are allowed to connect via SSH, as root, to the VSI. Can contain one or more IDs. The list of SSH Keys is available here: https://cloud.ibm.com/vpc-ext/compute/sshKeys."
	validation {
		condition     = var.SSH_KEYS == [] ? false : true && var.SSH_KEYS == [""] ? false : true
		error_message = "At least one SSH KEY is needed to be able to access the VSI."
	}
}

variable "BASTION_FLOATING_IP" {
	type		= string
	description = "The FLOATING IP of the Bastion Server."
}

variable "RESOURCE_GROUP" {
  type        = string
  description = "The name of an EXISTING Resource Group for VSIs and Volumes resources. The list of Resource Groups is available here: https://cloud.ibm.com/account/resource-groups"
  default     = "Default"
}

variable "REGION" {
	type		= string
	description	= "The cloud region where to deploy the solution. The regions and zones for VPC are listed here: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc. Review supported locations in IBM Cloud Schematics here: https://cloud.ibm.com/docs/schematics?topic=schematics-locations."
	validation {
		condition     = contains(["eu-de", "eu-gb", "us-south", "us-east", "ca-tor", "au-syd", "jp-osa", "jp-tok", "eu-es", "br-sao"], var.REGION )
		error_message = "The REGION must be one of: eu-de, eu-gb, us-south, us-east, ca-tor, au-syd, jp-osa, jp-tok, eu-es, br-sao."
	}
}

variable "ZONE" {
	type		= string
	description	= "The cloud zone where to deploy the solution."
	validation {
		condition     = length(regexall("^(eu-de|eu-gb|us-south|us-east|ca-tor|au-syd|jp-osa|jp-tok|eu-es|br-sao)-(1|2|3)$", var.ZONE)) > 0
		error_message = "The ZONE is not valid."
	}
}

variable "VPC" {
	type		= string
	description = "The name of an EXISTING VPC. The list of VPCs is available here: https://cloud.ibm.com/vpc-ext/network/vpcs."
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.VPC)) > 0
		error_message = "The VPC name is not valid."
	}
}

variable "SUBNET" {
	type		= string
	description = "The name of an EXISTING Subnet. The list of Subnets is available here: https://cloud.ibm.com/vpc-ext/network/subnets."
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.SUBNET)) > 0
		error_message = "The SUBNET name is not valid."
	}
}

variable "SECURITY_GROUP" {
	type		= string
	description = "The name of an EXISTING Security group. The list of Security Groups is available here: https://cloud.ibm.com/vpc-ext/network/securityGroups."
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.SECURITY_GROUP)) > 0
		error_message = "The SECURITY_GROUP name is not valid."
	}
}

variable "DB_HOSTNAME" {
	type		= string
	description = "The Hostname for the HANA VSI. The hostname should be up to 13 characters as required by SAP. For more information on rules regarding hostnames for SAP systems, check SAP Note 611361: \"Hostnames of SAP ABAP Platform servers\"."
	validation {
		condition     = length(var.DB_HOSTNAME) <= 13 && length(regexall("^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$", var.DB_HOSTNAME)) > 0
		error_message = "The DB_HOSTNAME is not valid."
	}
}

variable "DB_PROFILE" {
	type		= string
	description = "The instance profile used for SAP HANA VSI. The list of certified profiles for SAP HANA in IBM VPC: https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc"
	default		= "mx2-16x128"
	validation {
		condition     = contains(keys(jsondecode(file("modules/db-vsi/files/hana_vm_volume_layout.json")).profiles), var.DB_PROFILE)
		error_message = "The chosen storage PROFILE for HANA VSI \"${var.DB_PROFILE}\" is not a certified storage profile. Please, chose the appropriate certified storage PROFILE for the HANA VSI from  https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc . Make sure the selected PROFILE is certified for the selected OS type and for the proceesing type (SAP Business One, OLTP, OLAP)"
	}
}

variable "DB_IMAGE" {
	type		= string
	description = "The OS image used for HANA VSI (See Obs*). A list of images is available here: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images."
	default		= "ibm-redhat-8-6-amd64-sap-hana-6"
	validation {
		condition     = length(regexall("^(ibm-redhat-8-6-amd64-sap-hana|ibm-redhat-8-4-amd64-sap-hana|ibm-sles-15-3-amd64-sap-hana|ibm-sles-15-4-amd64-sap-hana)-[0-9][0-9]*", var.DB_IMAGE)) > 0
		error_message = "The OS SAP DB_IMAGE should be one of  \"ibm-sles-15-3-amd64-sap-hana-x\", \"ibm-sles-15-4-amd64-sap-hana-x\", \"ibm-redhat-8-4-amd64-sap-hana-x\" or \"ibm-redhat-8-6-amd64-sap-hana-x\"."
 }
}

variable "APP_HOSTNAME" {
	type		= string
	description = "The Hostname for the SAP Application VSI. The hostname should be up to 13 characters as required by SAP. For more information on rules regarding hostnames for SAP systems, check SAP Note 611361: \"Hostnames of SAP ABAP Platform servers\"."
	validation {
		condition     = length(var.APP_HOSTNAME) <= 13 && length(regexall("^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$", var.APP_HOSTNAME)) > 0
		error_message = "The APP_HOSTNAME is not valid."
	}
}

variable "APP_PROFILE" {
	type		= string
	description = "The instance profile used for SAP Application VSI. A list of profiles is available here: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles. For more information about supported DB/OS and IBM Gen 2 Virtual Server Instances (VSI), check SAP Note 2927211: \"SAP Applications on IBM Virtual Private Cloud\"."
	default		= "bx2-4x16"
}

variable "APP_IMAGE" {
	type		= string
	description = "The OS image used for SAP Application VSI. A list of images is available here: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images."
	default		= "ibm-redhat-8-6-amd64-sap-applications-6"
	validation {
			condition     = length(regexall("^(ibm-redhat-8-6-amd64-sap-applications|ibm-redhat-8-4-amd64-sap-applications|ibm-sles-15-3-amd64-sap-applications|ibm-sles-15-4-amd64-sap-applications)-[0-9][0-9]*", var.APP_IMAGE)) > 0
			error_message = "The OS SAP APP-IMAGE must be one of \"ibm-redhat-8-6-amd64-sap-applications-x\" ,  \"ibm-redhat-8-4-amd64-sap-applications-x\" ,  \" ibm-sles-15-4-amd64-sap-applications-x\" or \"ibm-sles-15-3-amd64-sap-applications-x\"."
 }
}

data "ibm_is_instance" "app-vsi-1" {
  depends_on = [module.app-vsi]
  name    =  var.APP_HOSTNAME
}

data "ibm_is_instance" "db-vsi-1" {
  depends_on = [module.db-vsi]
  name    =  var.DB_HOSTNAME
}

##############################################################
# The variables and data sources used in SAP Ansible Modules.
##############################################################

variable "HANA_SID" {
	type		= string
	description = "The SAP system ID identifies the SAP HANA system."
	default		= "HDB"
	validation {
		condition     = length(regexall("^[a-zA-Z][a-zA-Z0-9][a-zA-Z0-9]$", var.HANA_SID)) > 0  && !contains(["ADD", "ALL", "AMD", "AND", "ANY", "ARE", "ASC", "AUX", "AVG", "BIT", "CDC", "COM", "CON", "DBA", "END", "EPS", "FOR", "GET", "GID", "IBM", "INT", "KEY", "LOG", "LPT", "MAP", "MAX", "MIN", "MON", "NIX", "NOT", "NUL", "OFF", "OLD", "OMS", "OUT", "PAD", "PRN", "RAW", "REF", "ROW", "SAP", "SET", "SGA", "SHG", "SID", "SQL", "SUM", "SYS", "TMP", "TOP", "UID", "USE", "USR", "VAR"], var.HANA_SID)
		error_message = "The HANA_SID is not valid."
	}
}

variable "HANA_SYSNO" {
	type		= string
	description = "The instance number of the SAP HANA system."
	default		= "00"
	validation {
		condition     = var.HANA_SYSNO >= 0 && var.HANA_SYSNO <=97
		error_message = "The HANA_SYSNO is not valid."
	}
}

variable "HANA_TENANT" {
	type		= string
	description = "The name of the SAP HANA tenant."
	default		= "NWD"
	validation {
		condition     = length(regexall("^[A-Za-z0-9-_]+$", var.HANA_TENANT)) > 0  && !contains(["ADD", "ALL", "AMD", "AND", "ANY", "ARE", "ASC", "AUX", "AVG", "BIT", "CDC", "COM", "CON", "DBA", "END", "EPS", "FOR", "GET", "GID", "IBM", "INT", "KEY", "LOG", "LPT", "MAP", "MAX", "MIN", "MON", "NIX", "NOT", "NUL", "OFF", "OLD", "OMS", "OUT", "PAD", "PRN", "RAW", "REF", "ROW", "SAP", "SET", "SGA", "SHG", "SID", "SQL", "SUM", "SYS", "TMP", "TOP", "UID", "USE", "USR", "VAR"], var.HANA_TENANT)
		error_message = "The name of SAP HANA tenant HANA_TENANT is not valid."
	}
}

variable "HANA_MAIN_PASSWORD" {
	type		= string
	sensitive = true
	description = "Common password for all users that are created during the installation."
	validation {
		condition     = length(regexall("^(.{0,7}|.{15,}|[^0-9a-zA-Z]*)$", var.HANA_MAIN_PASSWORD)) == 0 && length(regexall("^[^0-9_][0-9a-zA-Z!@#$_]+$", var.HANA_MAIN_PASSWORD)) > 0
		error_message = "The HANA_MAIN_PASSWORD is not valid."
	}
}

variable "HANA_SYSTEM_USAGE" {
	type		= string
	description = "System Usage. Default: \"custom\". Valid values: \"production\", \"test\", \"development\", \"custom\"."
	default		= "custom"
	validation {
		condition     = contains(["production", "test", "development", "custom" ], var.HANA_SYSTEM_USAGE )
		error_message = "The hana_system_usage must be one of: production, test, development, custom."
	}
}

variable "HANA_COMPONENTS" {
	type		= string
	description = "SAP HANA Components. Default: \"server\". Valid values: \"all\", \"client\", \"es\", \"ets\", \"lcapps\", \"server\", \"smartda\", \"streaming\", \"rdsync\", \"xs\", \"studio\", \"afl\", \"sca\", \"sop\", \"eml\", \"rme\", \"rtl\", \"trp\"."
	default		= "server"
	validation {
		condition     = contains(["all", "client", "es", "ets", "lcapps", "server", "smartda", "streaming", "rdsync", "xs", "studio", "afl", "sca", "sop", "eml", "rme", "rtl", "trp" ], var.HANA_COMPONENTS )
		error_message = "The hana_components must be one of: all, client, es, ets, lcapps, server, smartda, streaming, rdsync, xs, studio, afl, sca, sop, eml, rme, rtl, trp."
	}
}

variable "KIT_SAPHANA_FILE" {
	type		= string
	description = "Path to SAP HANA ZIP file, as downloaded from SAP Support Portal."
	default		= "/storage/HANADB/SP07/Rev73/51057281.ZIP"
}

variable "SAP_SID" {
	type		= string
	description = "The SAP system ID identifies the entire SAP system."
	default		= "NWD"
	validation {
		condition     = length(regexall("^[a-zA-Z][a-zA-Z0-9][a-zA-Z0-9]$", var.SAP_SID)) > 0 && !contains(["ADD", "ALL", "AMD", "AND", "ANY", "ARE", "ASC", "AUX", "AVG", "BIT", "CDC", "COM", "CON", "DBA", "END", "EPS", "FOR", "GET", "GID", "IBM", "INT", "KEY", "LOG", "LPT", "MAP", "MAX", "MIN", "MON", "NIX", "NOT", "NUL", "OFF", "OLD", "OMS", "OUT", "PAD", "PRN", "RAW", "REF", "ROW", "SAP", "SET", "SGA", "SHG", "SID", "SQL", "SUM", "SYS", "TMP", "TOP", "UID", "USE", "USR", "VAR"], var.SAP_SID)
		error_message = "The SAP_SID is not valid."
	}
}

variable "SAP_ASCS_INSTANCE_NUMBER" {
	type		= string
	description = "Technical identifier for internal processes of ASCS."
	default		= "01"
	validation {
		condition     = var.SAP_ASCS_INSTANCE_NUMBER >= 0 && var.SAP_ASCS_INSTANCE_NUMBER <=97
		error_message = "The SAP_ASCS_INSTANCE_NUMBER is not valid."
	}
}

variable "SAP_CI_INSTANCE_NUMBER" {
	type		= string
	description = "Technical identifier for internal processes of CI."
	default		= "00"
	validation {
		condition     = var.SAP_CI_INSTANCE_NUMBER >= 0 && var.SAP_CI_INSTANCE_NUMBER <=97
		error_message = "The SAP_CI_INSTANCE_NUMBER is not valid."
	}
}

variable "SAP_MAIN_PASSWORD" {
	type		= string
	sensitive = true
	description = "Common password for all users that are created during the installation."
	validation {
		condition     = length(regexall("^(.{0,9}|.{15,}|[^0-9]*)$", var.SAP_MAIN_PASSWORD)) == 0 && length(regexall("^[^0-9_][0-9a-zA-Z@#$_]+$", var.SAP_MAIN_PASSWORD)) > 0
		error_message = "The SAP_MAIN_PASSWORD is not valid."
	}
}

variable "HDB_CONCURRENT_JOBS" {
	type		= string
	description = "Number of concurrent jobs used to load and/or extract archives to HANA Host."
	default		= "12"
	validation {
		condition     = var.HDB_CONCURRENT_JOBS >= 1 && var.HDB_CONCURRENT_JOBS <=25
		error_message = "The HDB_CONCURRENT_JOBS is not valid."
	}
}

variable "KIT_SAPCAR_FILE" {
	type		= string
	description = "Path to sapcar binary, as downloaded from SAP Support Portal."
	default		= "/storage/NW75HDB/SAPCAR_1300-70007716.EXE"
}

variable "KIT_SWPM_FILE" {
	type		= string
	description = "Path to SWPM archive (SAR), as downloaded from SAP Support Portal."
	default		= "/storage/NW75HDB/SWPM10SP42_0-20009701.SAR"
}

variable "KIT_SAPEXE_FILE" {
	type		= string
	description = "Path to SAP Kernel OS archive (SAR), as downloaded from SAP Support Portal."
	default		= "/storage/NW75HDB/KERNEL/754/SAPEXE_400-80007612.SAR"
}

variable "KIT_SAPEXEDB_FILE" {
	type		= string
	description = "Path to SAP Kernel DB archive (SAR), as downloaded from SAP Support Portal."
	default		= "/storage/NW75HDB/KERNEL/754/SAPEXEDB_400-80007611.SAR"
}

variable "KIT_IGSEXE_FILE" {
	type		= string
	description = "Path to IGS archive (SAR), as downloaded from SAP Support Portal."
	default		= "/storage/NW75HDB/KERNEL/754/igsexe_4-80007786.sar"
}

variable "KIT_IGSHELPER_FILE" {
	type		= string
	description = "Path to IGS Helper archive (SAR), as downloaded from SAP Support Portal."
	default		= "/storage/NW75HDB/igshelper_17-10010245.sar"
}

variable "KIT_SAPHOSTAGENT_FILE" {
	type		= string
	description = "Path to SAP Host Agent archive (SAR), as downloaded from SAP Support Portal."
	default		= "/storage/NW75HDB/SAPHOSTAGENT65_65-80004822.SAR"
}

variable "KIT_HDBCLIENT_FILE" {
	type		= string
	description = "Path to HANA DB client archive (SAR), as downloaded from SAP Support Portal."
	default		= "/storage/NW75HDB/IMDB_CLIENT20_022_27-80002082.SAR"
}

variable "KIT_NWHANA_EXPORT_FILE" {
	type		= string
	description = "Path to Netweaver Installation Export ZIP file. The archive downloaded from SAP Support Portal should be present in this path."
	default		= "/storage/NW75HDB/ABAPEXP/51050829_3.ZIP"
}