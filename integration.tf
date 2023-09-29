#### Ansible inventory.

resource "local_file" "ansible_inventory" {
  depends_on = [ module.db-vsi , module.app-vsi  ]
  content = <<-DOC
all:
  hosts:
    hdb_host:
      ansible_host: "${data.ibm_is_instance.db-vsi-1.primary_network_interface[0].primary_ip[0].address}"
    app_host:
      ansible_host: "${data.ibm_is_instance.app-vsi-1.primary_network_interface[0].primary_ip[0].address}"
    DOC
  filename = "ansible/inventory.yml"
}

#### Export Terraform saphana variable values to an Ansible var_file.

resource "local_file" "db_ansible_saphana-vars" {
  depends_on = [ module.db-vsi ]
  content = <<-DOC
---
#Ansible vars_file containing variable values passed from Terraform.
#Generated by "terraform plan&apply" command.

#HANA DB configuration
hana_sid: "${var.HANA_SID}"
hana_sysno: "${var.HANA_SYSNO}"
hana_main_password: "${var.HANA_MAIN_PASSWORD}"
hana_system_usage: "${var.HANA_SYSTEM_USAGE}"
hana_components: "${var.HANA_COMPONENTS}"

#SAP HANA Installation kit path
kit_saphana_file: "${var.KIT_SAPHANA_FILE}"
...
    DOC
  filename = "ansible/saphana-vars.yml"
}

#### Export Terraform nwapp variable values to an Ansible var_file.

resource "local_file" "app_ansible_nwapp-vars" {
  depends_on = [ module.db-vsi ]
  content = <<-DOC
---
#Ansible vars_file containing variable values passed from Terraform.
#Generated by "terraform plan&apply" command.

#SAP system configuration
sap_sid: "${var.SAP_SID}"
sap_ascs_instance_number: "${var.SAP_ASCS_INSTANCE_NUMBER}"
sap_ci_instance_number: "${var.SAP_CI_INSTANCE_NUMBER}"
sap_main_password: "${var.SAP_MAIN_PASSWORD}"

#HANA config
hdb_host: "${data.ibm_is_instance.db-vsi-1.primary_network_interface[0].primary_ip[0].address}"
hdb_sid: "${var.HANA_SID}"
hdb_instance_number: "${var.HANA_SYSNO}"
hdb_main_password: "${var.HANA_MAIN_PASSWORD}"
# Number of concurrent jobs used to load and/or extract archives to HANA Host
hdb_concurrent_jobs: "${var.HDB_CONCURRENT_JOBS}"

#SAP NW APP Installation kit path
kit_sapcar_file: "${var.KIT_SAPCAR_FILE}"
kit_swpm_file: "${var.KIT_SWPM_FILE}"
kit_sapexe_file: "${var.KIT_SAPEXE_FILE}"
kit_sapexedb_file: "${var.KIT_SAPEXEDB_FILE}"
kit_igsexe_file: "${var.KIT_IGSEXE_FILE}"
kit_igshelper_file: "${var.KIT_IGSHELPER_FILE}"
kit_saphotagent_file: "${var.KIT_SAPHOSTAGENT_FILE}"
kit_hdbclient_file: "${var.KIT_HDBCLIENT_FILE}"
kit_nwhana_export: "${var.KIT_NWHANA_EXPORT}"
...
    DOC
  filename = "ansible/nwapp-vars.yml"
}
