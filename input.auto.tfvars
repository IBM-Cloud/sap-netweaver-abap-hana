# General VPC variables:
REGION			= ""                                                         # EXISTING Region.
ZONE			= ""                                                         # EXISTING Zone. 
VPC				= ""                                                         # EXISTING VPC name
SECURITY_GROUP	= ""                                                         # EXISTING security group name
RESOURCE_GROUP  = "Default"                                                  # EXISTING Resource group name
SUBNET			= ""                                                         # EXISTING Subnet name
SSH_KEYS        = []                                                         # IBM Cloud SSH Keys ID list to access the VSIs.
ID_RSA_FILE_PATH = "ansible/id_rsa"                                          # The file path for private_ssh_key. Example: ansible/id_rsa_nw_abap_hana


# SAP Database VSI variables:
DB-HOSTNAME		= "sapnwhdb"
DB-PROFILE		= "mx2-16x128"
DB-IMAGE		= "ibm-redhat-8-6-amd64-sap-hana-2"

# SAP APPs VSI variables:
APP-HOSTNAME	= "sapnwci"
APP-PROFILE		= "bx2-4x16"
APP-IMAGE		= "ibm-redhat-8-6-amd64-sap-applications-2"

#HANA DB configuration
hana_sid = "HDB"
hana_sysno = "00"
hana_system_usage = "custom"
hana_components = "server"

#SAP HANA Installation kit path
kit_saphana_file = "/storage/HANADB/51055299.ZIP"

#SAP system configuration
sap_sid = "NWD"
sap_ascs_instance_number = "01"
sap_ci_instance_number = "00"

# Number of concurrent jobs used to load and/or extract archives to HANA Host
hdb_concurrent_jobs = "12"

#SAP NW APP Installation kit path
kit_sapcar_file = "/storage/NW75HDB/SAPCAR_1010-70006178.EXE"
kit_swpm_file = "/storage/NW75HDB/SWPM10SP31_7-20009701.SAR"
kit_sapexe_file = "/storage/NW75HDB/SAPEXE_801-80002573.SAR"
kit_sapexedb_file = "/storage/NW75HDB/SAPEXEDB_801-80002572.SAR"
kit_igsexe_file = "/storage/NW75HDB/igsexe_13-80003187.sar"
kit_igshelper_file = "/storage/NW75HDB/igshelper_17-10010245.sar"
kit_saphotagent_file = "/storage/NW75HDB/SAPHOSTAGENT51_51-20009394.SAR"
kit_hdbclient_file = "/storage/NW75HDB/IMDB_CLIENT20_009_28-80002082.SAR"
kit_nwhana_export = "/storage/NW75HDB/ABAPEXP"