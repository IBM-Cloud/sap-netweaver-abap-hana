# SAP Netweaver ABAP on HANA DB Stack Deployment

## Description
This automation solution is designed for the deployment of **SAP Netweaver ABAP on HANA DB Stack**. The SAP solution will be deployed on top of one of the following Operating Systems: **SUSE Linux Enterprise Server 15 SP 4 for SAP, SUSE Linux Enterprise Server 15 SP 3 for SAP,  Red Hat Enterprise Linux 8.6 for SAP, Red Hat Enterprise Linux 8.4 for SAP** in an existing IBM Cloud Gen2 VPC, using an existing [bastion host with secure remote SSH access](https://github.com/IBM-Cloud/sap-bastion-setup).

The solution is based on Terraform scripts and Ansible playbooks and it is implementing a 'reasonable' set of best practices for SAP hosts configuration.

**It contains:**
- Terraform scripts for the deployment of two servers, in an EXISTING VPC, with Subnet and Security Group. The servers are intended to be used: one for the data base instance and the other for the application instance. The automation has support for the following versions: Terraform >= 1.5.7 and IBM Cloud provider for Terraform >= 1.57.0.  Note: The deployment was validated with Terraform 1.9.2
- Bash scripts used for the checking of the prerequisites required by SAP servers deployment and for the integration into a single step the provisioning of the servers and the **SAP Netweaver ABAP on HANA DB Stack** installation.
- Ansible scripts to configure the LVM and filesystems, the OS parameters, a Three Tier SAP Netweaver ABAP primary application server and a HANA 2.0 node.
Please note that Ansible is started by Terraform and must be available on the same host.

## Contents:
- [1.1 Installation media](#11-installation-media)
- [1.2 Server Configuration](#12-server-configuration)
- [1.3 VPC Configuration](#13-vpc-configuration)
- [1.4 Files description and structure](#14-files-description-and-structure)
- [2.1 Prerequisites](#21-prerequisites)
- [2.2 General Input variables](#22-general-input-variables)
- [2.3 Executing the deployment of **SAP Netweaver on HANA DB Stack** in GUI (Schematics)](#23-executing-the-deployment-of-sap-netweaver-on-hana-db-stack-in-gui-schematics)
- [2.4 Executing the deployment of **SAP Netweaver on HANA DB Stack** in CLI](#24-executing-the-deployment-of-sap-netweaver-on-hana-db-stack-in-cli)
- [3.1 Related links](#31-related-links)

## 1.1 Installation media
SAP HANA installation media used for this deployment is the default one for **SAP HANA, platform edition 2.0 SPS07** available at SAP Support Portal under *INSTALLATION AND UPGRADE* area and it has to be provided manually in the input parameter file.

SAP Netweaver installation media used for this deployment is the default one for **SAP Netweaver 7.5** available at SAP Support Portal under *INSTALLATION AND UPGRADE* area and it has to be provided manually in the input parameter file.

## 1.2 Server Configuration
The Servers are deployed with one of the following Operating Systems for DB server: **Red Hat Enterprise Linux 8.6 for SAP HANA (amd64)**, **Red Hat Enterprise Linux 8.4 for SAP HANA (amd64)**, **Suse Linux Enterprise Server 15 SP 4 for SAP HANA (amd64)**, **Suse Linux Enterprise Server 15 SP 3 for SAP HANA (amd6)** and with one of the following Operating Systems for APP server: **Red Hat Enterprise Linux 8.6 for SAP Applications (amd64)**, **Red Hat Enterprise Linux 8.4 for SAP Applications (amd64)**, **Suse Enterprise Linux 15 SP4 for SAP Applications (amd64)**, **Suse Enterprise Linux 15 SP3 for SAP Applications (amd64)**. The SSH keys are configured to allow root user access. The following storage volumes are creating during the provisioning:

HANA DB VSI Disks:
- the disk sizes depend on the selected profile, according to [Intel Virtual Server certified profiles on VPC infrastructure for SAP HANA](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc) - Last updated 2023-12-28

Note: For SAP HANA on a VSI, according to [Intel Virtual Server certified profiles on VPC infrastructure for SAP HANA](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc#vx2d-16x224) - Last updated 2022-01-28 and to [Storage design considerations](https://cloud.ibm.com/docs/sap?topic=sap-storage-design-considerations) - Last updated 2024-01-25, LVM will be used for **`/hana/data`**, **`hana/log`**, **`/hana/shared`** and **`/usr/sap`**, for all storage profiles, with the following exceptions:
- **`/hana/data`** and **`/hana/shared`** for the following profiles: **`vx2d-44x616`** and **`vx2d-88x1232`**
- **`/hana/shared`** for the following profiles: **`vx2d-144x2016`**, **`vx2d-176x2464`**, **`ux2d-36x1008`**, **`ux2d-48x1344`**, **`ux2d-72x2016`**, **`ux2d-100x2800`**, **`ux2d-200x5600`**.

For example, in case of deploying a SAP HANA on a VSI, using the value `mx2-16x128` for the VSI profile , the automation will execute the following storage setup:  
- 3 volumes x 500 GB each for `<sid>_hana_vg` volume group
  - the volume group will contain the following logical volumes (created with three stripes):
    - `<sid>_hana_data_lv` - size 988 GB
    - `<sid>_hana_log_lv` - size 256 GB
    - `<sid>_hana_shared` - size 256 GB
- 1 volume x 50 GB for `/usr/sap` (volume group: `<sid>_usr_sap_vg`, logical volume: `<sid>_usr_sap_lv`)
- 1 volume x 10 GB for a 2 GB SWAP logical volume (volume group: `<sid>_swap_vg`, logical volume: `<sid>_swap_lv`)

SAP APPs VSI Disks:
- 1 disk with 10 IOPS / GB - SWAP (the size depends on the OS profile used, for `bx2-4x16` the size will be 48 GB)
- 1 x 128 GB disk with 10 IOPS / GB - DATA

In order to perform the deployment you can use either the CLI component or the GUI component (Schematics) of the automation solution.

## 1.3 VPC Configuration
The Security Rules inherited from BASTION deployment are the following:
- Allow all traffic in the Security group for private networks.
- Allow outbound traffic  (ALL for port 53, TCP for ports 80, 443, 8443)
- Allow inbound SSH traffic (TCP for port 22) from IBM Schematics Servers.

 ## 1.4 Files description and structure
 - `modules` - directory containing the terraform modules
 - `main.tf` - contains the configuration of the VSI for the deployment of the current SAP solution.
 - `output.tf` - contains the code for the information to be displayed after the VSI is created (Hostname, Private IP).
 - `integration*.tf` - contains the integration code that makes the SAP variables from Terraform available to Ansible.
 - `provider.tf` - contains the IBM Cloud Provider data in order to run `terraform init` command.
 - `terraform.tfvars` - contains the IBM Cloud API key referenced in `provider.tf` (dynamically generated)
 - `variables.tf` - contains variables for the VPC and VSI
 - `versions.tf` - contains the minimum required versions for terraform and IBM Cloud provider.

## 2.1 Prerequisites

- A Deployment Server (BASTION Server) in the same VPC should exist. For more information, see https://github.com/IBM-Cloud/sap-bastion-setup.
- On the Deployment Server download the SAP kits from the SAP Portal to your Deployment Server. Make note of the download locations. Ansible decompresses all of the archive kits.
- Create or retrieve an IBM Cloud API key. The API key is used to authenticate with the IBM Cloud platform and to determine your permissions for IBM Cloud services.
- Create or retrieve your SSH key ID. You need the 40-digit UUID for the SSH key, not the SSH key name.

## 2.2 General Input variables
The following parameters can be set:

**General input parameters:**

Parameter | Description
----------|------------
IBMCLOUD_API_KEY | IBM Cloud API key (Sensitive* value). The IBM Cloud API Key can be created [here](https://cloud.ibm.com/iam/apikeys)
SSH_KEYS | List of SSH Keys UUIDs that are allowed to SSH as root to the server. Can contain one or more IDs. The list of SSH Keys is available [here](https://cloud.ibm.com/vpc-ext/compute/sshKeys). <br /> Sample input (use your own SSH UUIDs from IBM Cloud):<br /> [ "r010-57bfc315-f9e5-46bf-bf61-d87a24a9ce7a" , "r010-3fcd9fe7-d4a7-41ce-8bb3-d96e936b2c7e" ]
BASTION_FLOATING_IP | BASTION FLOATING IP. It can be copied from the Bastion Server Deployment "OUTPUTS" at the end of "Apply plan successful" message.
RESOURCE_GROUP | The name of an EXISTING Resource Group for servers and Volumes resources. <br /> Default value: "Default". The list of Resource Groups is available [here](https://cloud.ibm.com/account/resource-groups).
REGION | The cloud region where to deploy the solution. <br /> The regions and zones for VPC are listed [here](https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc). <br /> Review supported locations in IBM Cloud Schematics [here](https://cloud.ibm.com/docs/schematics?topic=schematics-locations).<br /> Sample value: eu-de.
ZONE | The cloud zone where to deploy the solution. <br /> Sample value: eu-de-2.
VPC | The name of an EXISTING VPC. The list of VPCs is available [here](https://cloud.ibm.com/vpc-ext/network/vpcs)
SUBNET | The name of an EXISTING Subnet. The list of Subnets is available [here](https://cloud.ibm.com/vpc-ext/network/subnets). 
SECURITY_GROUP | The name of an EXISTING Security group. The list of Security Groups is available [here](https://cloud.ibm.com/vpc-ext/network/securityGroups). 

**Server input parameters**
Parameter | Description
----------|------------
DB_HOSTNAME | The Hostname for the HANA Server. The hostname should be up to 13 characters as required by SAP.  For more information on rules regarding hostnames for SAP systems, check [SAP Note 611361: Hostnames of SAP ABAP Platform servers](https://launchpad.support.sap.com/#/notes/%20611361)
DB_PROFILE | The instance profile used for the SAP HANA Server. The list of the certified profiles for SAP HANA on a VSI is available [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc). <br> Details about all x86 instance profiles are available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles). <br>  For more information about supported DB/OS and IBM Gen 2 Servers, check [SAP Note 2927211: SAP Applications on IBM Virtual Private Cloud](https://launchpad.support.sap.com/#/notes/2927211) <br /> Default value: "mx2-16x128"
DB_IMAGE | The OS image used for HANA Server (See Obs*). A list of images is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-about-images).<br /> Default value: "ibm-redhat-8-6-amd64-sap-hana-6"
APP_HOSTNAME | The Hostname for the SAP Application VSI. The hostname should be up to 13 characters as required by SAP.  For more information on rules regarding hostnames for SAP systems, check [SAP Note 611361: Hostnames of SAP ABAP Platform servers](https://launchpad.support.sap.com/#/notes/%20611361)
APP_PROFILE |  The instance profile used for SAP Application VSI. A list of profiles is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles) <br>  For more information about supported DB/OS and IBM Gen 2 Virtual Server Instances (VSI), check [SAP Note 2927211: SAP Applications on IBM Virtual Private Cloud](https://launchpad.support.sap.com/#/notes/2927211) <br /> Default value: "bx2-4x16"
APP_IMAGE | The OS image used for SAP Application VSI (See Obs*). A list of images is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-about-images).<br /> Default value: "ibm-redhat-8-6-amd64-sap-applications-6"

**SAP input parameters**
Parameter | Description | Requirements
----------|-------------|-------------
HANA_SID | The SAP system ID identifies the SAP HANA system. <br /> _(See Obs.*)_ <br /> Default value: "HDB"| <ul><li>Consists of exactly three alphanumeric characters</li><li>Has a letter for the first character</li><li>Does not include any of the reserved IDs listed in SAP Note 1979280</li></ul>|
HANA_TENANT | SAP HANA tenant name. <br /> Default value: "NWD" | 
HANA_SYSNO | Specifies the instance number of the SAP HANA system <br /> Default value: "00" | <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
HANA_SYSTEM_USAGE  | System Usage <br /> Default value: "custom"| Valid values: production, test, development, custom
HANA_COMPONENTS | SAP HANA Components <br /> Default value: "server" | Valid values: all, client, es, ets, lcapps, server, smartda, streaming, rdsync, xs, studio, afl, sca, sop, eml, rme, rtl, trp
KIT_SAPHANA_FILE | Path to SAP HANA ZIP file (See Obs*). <br /> Default value: "/storage/HANADB/SP07/Rev73/51057281.ZIP"| As downloaded from SAP Support Portal
SAP_SID | The SAP system ID <SAPSID> identifies the entire SAP system <br /> Default value: "NWD" | <ul><li>Consists of exactly three alphanumeric characters</li><li>Has a letter for the first character</li><li>Does not include any of the reserved IDs listed in SAP Note 1979280</li></ul> 
SAP_ASCS_INSTANCE_NUMBER | Technical identifier for internal processes of ASCS <br /> Default value: "01"| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul> 
SAP_CI_INSTANCE_NUMBER | Technical identifier for internal processes of CI <br /> Default value: "00"| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul> 
HDB_CONCURRENT_JOBS | Number of concurrent jobs used to load and/or extract archives to HANA Host <br /> Default value: "23"| 
KIT_SAPCAR_FILE  | Path to sapcar binary <br /> Default value: "/storage/NW75HDB/SAPCAR_1300-70007716.EXE"| As downloaded from SAP Support Portal
KIT_SWPM_FILE | Path to SWPM archive (SAR) <br /> Default value: "/storage/NW75HDB/SWPM10SP42_0-20009701.SAR"| As downloaded from SAP Support Portal
KIT_SAPEXE_FILE | Path to SAP Kernel OS archive (SAR) <br /> Default value: "/storage/NW75HDB/KERNEL/754/SAPEXE_400-80007612.SAR"| As downloaded from SAP Support Portal
KIT_SAPEXEDB_FILE | Path to SAP Kernel DB archive (SAR) <br /> Default value: "/storage/NW75HDB/KERNEL/754/SAPEXEDB_400-80007611.SAR"| As downloaded from SAP Support Portal
KIT_IGSEXE_FILE | Path to IGS archive (SAR) <br /> Default value: "/storage/NW75HDB/KERNEL/754/igsexe_4-80007786.sar"| As downloaded from SAP Support Portal
KIT_IGSHELPER_FILE | Path to IGS Helper archive (SAR) <br /> Default value: "/storage/NW75HDB/igshelper_17-10010245.sar"| As downloaded from SAP Support Portal
KIT_SAPHOSTAGENT_FILE | Path to SAP Host Agent archive (SAR) <br /> Default value: "/storage/NW75HDB/SAPHOSTAGENT65_65-80004822.SAR"| As downloaded from SAP Support Portal
KIT_HDBCLIENT_FILE | Path to HANA DB client archive (SAR) <br /> Default value: "/storage/NW75HDB/IMDB_CLIENT20_022_27-80002082.SAR"| As downloaded from SAP Support Portal
KIT_NWHANA_EXPORT_FILE | Path to Netweaver Installation Export ZIP file <br /> Default value: "/storage/NW75HDB/ABAPEXP/51050829_3.ZIP"| The archive downloaded from SAP Support Portal should be present in this path

**Other SAP input parameters**
Parameter | Description | Requirements
----------|-------------|-------------
SAP_MAIN_PASSWORD | Common password for all users that are created during the installation | <ul><li>It must be 8 to 14 characters long</li><li>It must contain at least one digit (0-9)</li><li>It must not contain \ (backslash) and " (double quote)</li></ul>
HANA_MAIN_PASSWORD | HANA system master password | <ul><li>It must be 8 to 14 characters long</li><li>It must contain at least one digit (0-9)</li><li>It must not contain \ (backslash) and " (double quote)</li><li>Master Password must contain at least one upper-case character</li></ul>

**Obs**: <br />   

- **Sensitive** - The variable value is not displayed in your Schematics logs and it is hidden in the input field.<br />
- The following parameters should have the same values as the ones set for the BASTION server: REGION, ZONE, VPC, SUBNET, SECURITYGROUP.
- For any manual change in the terraform code, you have to make sure that you use a certified image based on the SAP NOTE: 2927211.

**Installation media validated for this solution:**

Component | Version | Filename
----------|-------------|-------------
SAPCAR | 7.53 | SAPCAR_1300-70007716.EXE
SOFTWARE PROVISIONING MGR | 1.0 | SWPM10SP42_0-20009701.SAR
SAP KERNEL | 7.54 64-BIT UNICODE | SAPEXE_400-80007612.SAR<br> SAPEXEDB_400-80007611.SAR
SAP IGS | 7.54 | igsexe_4-80007786.sar
SAP IGS HELPER | PL 17 | igshelper_17-10010245.sar
SAP HOST AGENT | 7.22 SP 65 | SAPHOSTAGENT65_65-80004822.SAR
HANA CLIENT | 2.22 | IMDB_CLIENT20_022_27-80002082.SAR
HANA DB | 2.0 SPS07 rev73 | 51057281.ZIP
SAP NW Export | 7.5 | 51050829_3.ZIP

**OS images validated for this solution:**

OS version | Image | Role
-----------|-----------|-----------
Red Hat Enterprise Linux 8.6 for SAP HANA (amd64) | ibm-redhat-8-6-amd64-sap-hana-6 | DB
Red Hat Enterprise Linux 8.6 for SAP Applications (amd64) | ibm-redhat-8-6-amd64-sap-applications-6 | APP
SUSE Linux Enterprise Server 15 SP4 for SAP HANA | ibm-sles-15-4-amd64-sap-hana-8 | DB
SUSE Linux Enterprise Server 15 SP4 for SAP Applications | ibm-sles-15-4-amd64-sap-applications-9 | APP
Red Hat Enterprise Linux 8.4 for SAP HANA (amd64) | ibm-redhat-8-4-amd64-sap-hana-10 | DB
Red Hat Enterprise Linux 8.4 for SAP Applications (amd64) | ibm-redhat-8-4-amd64-sap-applications-10 | APP
SUSE Linux Enterprise Server 15 SP3 for SAP HANA | ibm-sles-15-3-amd64-sap-hana-11 | DB
SUSE Linux Enterprise Server 15 SP3 for SAP Applications | ibm-sles-15-3-amd64-sap-applications-12 | APP

## 2.3 Executing the deployment of **SAP Netweaver ABAP on HANA DB Stack** in GUI (Schematics)

The solution is based on Terraform remote-exec and Ansible playbooks executed by Schematics.

The parameters that can be set in the Schematics workspace are described in [General input variables Section](#22-general-input-variables) section.

Beside [General input variables Section](#22-general-input-variables), the below ones, in IBM Schematics have specific description and GUI input options:

**Specific Input parameters:**

Parameter | Description
----------|------------
PRIVATE_SSH_KEY | id_rsa private SSH key content in OpenSSH format (Sensitive* value). This private SSH key should be used only during the terraform provisioning and it is recommended to be changed after the SAP deployment.
ID_RSA_FILE_PATH | The file path for the private ssh key. It will be automatically generated. If it is changed, it must contain the relative path from git repo folders. Example: ansible/id_rsa_nwhana

### Steps to follow

1.  Make sure that you have the [required IBM Cloud IAM
    permissions](https://cloud.ibm.com/docs/vpc?topic=vpc-managing-user-permissions-for-vpc-resources) to
    create and work with VPC infrastructure and you are [assigned the
    correct
    permissions](https://cloud.ibm.com/docs/schematics?topic=schematics-access) to
    create the workspace in Schematics and deploy resources.
2.  [Generate an SSH
    key](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys).
    The SSH key is required to access the provisioned VPC virtual server
    instances via the bastion host. After you have created your SSH key,
    make sure to [upload this SSH key to your IBM Cloud
    account](https://cloud.ibm.com/docs/vpc-on-classic-vsi?topic=vpc-on-classic-vsi-managing-ssh-keys#managing-ssh-keys-with-ibm-cloud-console) in
    the VPC region and resource group where you want to deploy the SAP solution
3.  Create the Schematics workspace:
    1.  From the IBM Cloud menu
    select [Schematics](https://cloud.ibm.com/schematics/overview).
        - Push the `Create workspace` button.
        - Provide the URL of the Github repository of this solution
        - Select the latest Terraform version.
        - Click on `Next` button
        - Provide a name, the resources group and location for your workspace
        - Push `Next` button
        - Review the provided information and then push `Create` button to create your workspace
    2.  On the workspace **Settings** page, 
        - In the **Input variables** section, review the default values for the input variables and provide alternatives if desired.
        - Click **Save changes**.
4.  From the workspace **Settings** page, click **Generate plan** 
5.  From the workspace **Jobs** page, the logs of your Terraform
    execution plan can be reviewed.
6.  Apply your Terraform template by clicking **Apply plan**.
7.  Review the logs to ensure that no errors occurred during the
    provisioning, modification, or deletion process.

    In the output of the Schematics `Apply Plan` the private IP address of the Servers, the hostname of the servers, the VPC and the Activity Tracker instance name will be displayed.

**Obs***: <br />
 - **SAP/HANA Passwords.**
The passwords for the SAP system will be hidden during the schematics apply step and will not be available after the deployment.

## 2.4 Executing the deployment of **SAP Netweaver on HANA DB Stack** in CLI

### IBM Cloud API Key
For the script configuration add your IBM Cloud API Key in terraform planning phase command 'terraform plan --out plan1'.
 
### Input parameter file
The solution is configured by editing the variable values in the file `input.auto.tfvars`. See the example below:

**General input parameters:**

```shell
##########################################################
# General & Default VPC variables for CLI deployment:
######################################################

REGION = "eu-de" 
# Region for the VSI. Supported regions: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
# Edit the variable value with your deployment Region.
# Example: REGION = "eu-de"

ZONE = "eu-de-1"
# Availability zone for VSI. Supported zones: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
# Edit the variable value with your deployment Zone.
# Example: ZONE = "eu-de-1"

VPC = "ic4sap"
# EXISTING VPC, previously created by the user in the same region as the VSI. The list of available VPCs: https://cloud.ibm.com/vpc-ext/network/vpcs
# Example: VPC = "ic4sap"

SECURITY_GROUP = "ic4sap-securitygroup"
# EXISTING Security group, previously created by the user in the same VPC. The list of available Security Groups: https://cloud.ibm.com/vpc-ext/network/securityGroups
# Example: SECURITY_GROUP = "ic4sap-securitygroup"

RESOURCE_GROUP = "wes-automation"
# EXISTING Resource group, previously created by the user. The list of available Resource Groups: https://cloud.ibm.com/account/resource-groups
# Example: RESOURCE_GROUP = "wes-automation"

SUBNET = "ic4sap-subnet"
# EXISTING Subnet in the same region and zone as the VSI, previously created by the user. The list of available Subnets: https://cloud.ibm.com/vpc-ext/network/subnets
# Example: SUBNET = "ic4sap-subnet"

SSH_KEYS = ["r010-8f72b994-c17f-4500-af8f-d05680374t3c", "r011-8f72v884-c17f-4500-af8f-d05900374t3c"]
# List of SSH Keys UUIDs that are allowed to SSH as root to the VSI. The SSH Keys should be created for the same region as the VSI. The list of available SSH Keys UUIDs: https://cloud.ibm.com/vpc-ext/compute/sshKeys
# Example: SSH_KEYS = ["r010-8f72b994-c17f-4500-af8f-d05680374t3c", "r011-8f72v884-c17f-4500-af8f-d05900374t3c"]
 
ID_RSA_FILE_PATH = "ansible/id_rsa"
# The id_rsa private key file path in OpenSSH format with 0600 permissions.
# This private key is used only during the terraform provisioning and it is recommended to be changed after the SAP deployment.
# It must contain the relative or absoute path from your Bastion.
# Examples: "ansible/id_rsa_nwhana" , "~/.ssh/id_rsa_nwhana" , "/root/.ssh/id_rsa".
```

**Server input parameters**

```shell
##########################################################
# SAP Database VSI variables:
##########################################################

DB_HOSTNAME = "sapnwhdb" 
# The hostname for the DB VSI. The hostname should be up to 13 characters, as required by SAP
# Example: DB_HOSTNAME = "sapnwhdb"

DB_PROFILE = "mx2-16x128"
# The instance profile used for the HANA VSI. The list of certified profiles for HANA VSIs: https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc
# Details about all x86 instance profiles: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles).
# For more information about supported DB/OS and IBM Gen 2 Virtual Server Instances (VSI), check [SAP Note 2927211: SAP Applications on IBM Virtual Private Cloud](https://launchpad.support.sap.com/#/notes/2927211) 
# Default value: "mx2-16x128"

DB_IMAGE = "ibm-redhat-8-6-amd64-sap-hana-6"
# OS image for DB VSI. Validated OS images for DB servers: ibm-redhat-8-6-amd64-sap-hana-6, ibm-redhat-8-4-amd64-sap-hana-10, ibm-sles-15-4-amd64-sap-hana-8, ibm-sles-15-3-amd64-sap-hana-11.
# The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
# Example: DB_IMAGE = "ibm-redhat-8-6-amd64-sap-hana-6"

##########################################################
# SAP APPs VSI variables
##########################################################

APP_HOSTNAME = "sapnwci" 
# The hostname for the APP VSI. The hostname should be up to 13 characters, as required by SAP
# Example: APP_HOSTNAME = "sapnwci"

APP_PROFILE = "bx2-4x16"
# The APP VSI profile. Supported profiles for DB VSI: bx2-4x16. The list of available profiles: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui

APP_IMAGE = "ibm-redhat-8-6-amd64-sap-applications-6"
# OS image for SAP APP VSI. Validated OS images for APP VSIs: ibm-redhat-8-6-amd64-sap-applications-6, ibm-redhat-8-4-amd64-sap-applications-10, ibm-sles-15-4-amd64-sap-applications-9, ibm-sles-15-3-amd64-sap-applications-12.
# The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
# Example: APP_IMAGE = "ibm-redhat-8-6-amd64-sap-applications-6" 
```

**SAP input parameters**

```shell
##########################################################
# SAP HANA configuration
##########################################################

HANA_SID = "HDB"
# SAP HANA system ID. Should follow the SAP rules for SID naming.
# Example: HANA_SID = "HDB"

HANA_SYSNO = "00"
# SAP HANA instance number. Should follow the SAP rules for instance number naming.
# Example: HANA_SYSNO = "01"

HANA_TENANT = "HDB"
# SAP HANA tenant name
# Example:HANA_TENANT = "HDB_TEN1"

HANA_SYSTEM_USAGE = "custom"
# System usage. Default: custom. Suported values: production, test, development, custom
# Example: HANA_SYSTEM_USAGE = "custom"

HANA_COMPONENTS = "server"
# SAP HANA Components. Default: server. Supported values: all, client, es, ets, lcapps, server, smartda, streaming, rdsync, xs, studio, afl, sca, sop, eml, rme, rtl, trp
# Example: HANA_COMPONENTS = "server"

KIT_SAPHANA_FILE = "/storage/HANADB/SP07/Rev73/51057281.ZIP"
# SAP HANA Installation kit path
# Validate SAP HANA versions on Red Hat 8 and Suse 15: HANA 2.0 SP 7 Rev 73, kit file: 51055299.ZIP
# Example for Red Hat 8 or Suse 15: KIT_SAPHANA_FILE = "/storage/HANADB/51055299.ZIP"

##########################################################
# SAP system configuration
##########################################################

SAP_SID = "NWA"
# SAP System ID

SAP_ASCS_INSTANCE_NUMBER = "01"
# The central ABAP service instance number. Should follow the SAP rules for instance number naming.
# Example: SAP_ASCS_INSTANCE_NUMBER = "01"

SAP_CI_INSTANCE_NUMBER = "00"
# The SAP central instance number. Should follow the SAP rules for instance number naming.
# Example: SAP_CI_INSTANCE_NUMBER = "00"

HDB_CONCURRENT_JOBS = "12"
# Number of concurrent jobs used to load and/or extract archives to HANA Host

##########################################################
#SAP NW APP Installation kit path
##########################################################

KIT_SAPCAR_FILE = "/storage/NW75HDB/SAPCAR_1300-70007716.EXE"
KIT_SWPM_FILE = "/storage/NW75HDB/SWPM10SP42_0-20009701.SAR"
KIT_SAPEXE_FILE = "/storage/NW75HDB/KERNEL/754/SAPEXE_400-80007612.SAR"
KIT_SAPEXEDB_FILE = "/storage/NW75HDB/KERNEL/754/SAPEXEDB_400-80007611.SAR"
KIT_IGSEXE_FILE = "/storage/NW75HDB/KERNEL/754/igsexe_4-80007786.sar"
KIT_IGSHELPER_FILE = "/storage/NW75HDB/igshelper_17-10010245.sar"
KIT_SAPHOSTAGENT_FILE = "/storage/NW75HDB/SAPHOSTAGENT65_65-80004822.SAR"
KIT_HDBCLIENT_FILE = "/storage/NW75HDB/IMDB_CLIENT20_022_27-80002082.SAR"
KIT_NWHANA_EXPORT_FILE = "/storage/NW75HDB/ABAPEXP/51050829_3.ZIP"
```

### Steps to follow:

For initializing terraform:

```shell
terraform init
```

For planning phase:

```shell
terraform plan --out plan1
# you will be asked for the following sensitive variables: 
'IBMCLOUD_API_KEY', 'SAP_MAIN_PASSWORD' and 'HANA_MAIN_PASSWORD'.
```

For apply phase:

```shell
terraform apply "plan1"
```

For destroy:

```shell
terraform destroy
# you will be asked for the following sensitive variables as a destroy confirmation phase:
'IBMCLOUD_API_KEY', 'SAP_MAIN_PASSWORD' and 'HANA_MAIN_PASSWORD'.

```

## 3.1 Related links:

- [How to create a BASTION/STORAGE VSI for SAP in IBM Schematics](https://github.com/IBM-Cloud/sap-bastion-setup)
- [Securely Access Remote Instances with a Bastion Host](https://www.ibm.com/cloud/blog/tutorial-securely-access-remote-instances-with-a-bastion-host)
- [VPNs for VPC overview: Site-to-site gateways and Client-to-site servers.](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-overview)
- [IBM Cloud Schematics](https://www.ibm.com/cloud/schematics)
