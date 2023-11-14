# SAP Netweaver on HANA DB Stack Deployment

## Description
This automation solution is designed for the deployment of **SAP Netweaver on HANA DB Stack**. The SAP solution will be deployed on top of one of the following Operating Systems: **SUSE Linux Enterprise Server 15 SP 4 for SAP, SUSE Linux Enterprise Server 15 SP 3 for SAP,  Red Hat Enterprise Linux 8.6 for SAP, Red Hat Enterprise Linux 8.4 for SAP** in an existing IBM Cloud Gen2 VPC, using an existing bastion host with secure remote SSH access.

In order to track the events specific to the resources deployed by this solution, the [IBM Cloud Activity Tracker](https://cloud.ibm.com/docs/activity-tracker?topic=activity-tracker-getting-started#gs_ov) to be used should be specified. IBM Cloud Activity Tracker service collects and stores audit records for API calls made to resources that run in the IBM Cloud. It can be used to monitor the activity of your IBM Cloud account, investigate abnormal activity and critical actions, and comply with regulatory audit requirements. In addition, you can be alerted on actions as they happen.

## Contents:

- [1.1 Installation media](#11-installation-media)
- [1.2 VSI Configuration](#12-vsi-configuration)
- [1.3 VPC Configuration](#13-vpc-configuration)
- [1.4 Files description and structure](#14-files-description-and-structure)
- [2.1 Prerequisites](#21-prerequisites)
- [2.2 Executing the deployment of **SAP Netweaver on HANA DB Stack** in GUI (Schematics)](#22-executing-the-deployment-of-sap-netweaver-on-hana-db-stack-in-gui-schematics)
- [2.3 Executing the deployment of **SAP Netweaver on HANA DB Stack** in CLI](#23-executing-the-deployment-of-sap-netweaver-on-hana-db-stack-in-cli)
- [3.1 Related links](#31-related-links)

## 1.1 Installation media
SAP HANA installation media used for this deployment is the default one for **SAP HANA, platform edition 2.0 SPS05** available at SAP Support Portal under *INSTALLATION AND UPGRADE* area and it has to be provided as input data.

SAP Netweaver installation media used for this deployment is the default one for **SAP Netweaver 7.5** available at SAP Support Portal under *INSTALLATION AND UPGRADE* area and it has to be provided manually in the input parameter file.


## 1.2 VSI Configuration
The VSI OS images that are supported for this solution are the following:

For Netweaver primary application server:
- ibm-redhat-8-6-amd64-sap-applications-4
- ibm-redhat-8-4-amd64-sap-applications-7
- ibm-sles-15-4-amd64-sap-applications-6
- ibm-sles-15-3-amd64-sap-applications-9

For HANA DB:
- ibm-redhat-8-6-amd64-sap-hana-4
- ibm-redhat-8-4-amd64-sap-hana-7
- ibm-sles-15-4-amd64-sap-hana-5
- ibm-sles-15-3-amd64-sap-hana-8

The VSIs will be accessible via SSH, as root user, based on the SSH key and IBM Cloud SSH keys UUID provided.  
The following storage volumes are created during provisioning for DB and SAP APP VSIs:

HANA DB VSI Disks:
- the disk sizes depend on the selected profile, according to [Intel Virtual Server certified profiles on VPC infrastructure for SAP HANA](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc) - Updated on 2023-03-08

Note: LVM will be used for **`/hana/data`**, **`hana/log`**, **`/hana/shared`** and **`/usr/sap`**, for all storage profiles, excepting **`vx2d-44x616`** and **`vx2d-88x1232`** profiles, where **`/hana/data`** and **`/hana/shared`** won't be manged by LVM, according to [Intel Virtual Server certified profiles on VPC infrastructure for SAP HANA](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc#vx2d-16x224) - Updated on 2023-03-08 and to [Storage design considerations](https://cloud.ibm.com/docs/sap?topic=sap-storage-design-considerations#hana-iaas-mx2-16x128-32x256-configure) - Updated on 2022-05-19

For example, in case of deploying a HANA VM, using the default value for VSI profile `mx2-16x128`, the automation will execute the following storage setup:  
- 3 volumes x 500 GB each for `<sid>_hana_vg` volume group
  - the volume group will contain the following logical volumes (created with three stripes):
    - `<sid>_hana_data_lv` - size 988 GB
    - `<sid>_hana_log_lv` - size 256 GB
    - `<sid>_hana_shared` - size 256 GB
- 1 volume x 50 GB for `/usr/sap` (volume group: `<sid>_usr_sap_vg`, logical volume: `<sid>_usr_sap_lv`)
- 1 volume x 10 GB for a 2 GB SWAP logical volume (volume group: `<sid>_swap_vg`, logical volume: `<sid>_swap_lv`)

SAP APPs VSI Disks:
- 1x 40 GB disk with 10 IOPS / GB - SWAP
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
 - `output.tf` - contains the code for the information to be displayed after the VSI is created (Hostname, Private IP, Activity Tracker Name).
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

## 2.2 Executing the deployment of **SAP Netweaver on HANA DB Stack** in GUI (Schematics)

The solution is based on Terraform remote-exec and Ansible playbooks executed by Schematics and it is implementing a 'reasonable' set of best practices for SAP VSI host configuration.

**It contains:**
- Terraform scripts for the deployment of two VSIs, in an EXISTING VPC, with Subnet and Security Group. The VSIs are intended to be used: one for the data base instance and the other for the application instance. The automation has support for the following versions: Terraform >= 1.5.7 and IBM Cloud provider for Terraform >= 1.57.0.  Note: The deployment was tested with Terraform 1.5.7
- Bash scripts used for the checking of the prerequisites required by SAP VSIs deployment and for the integration into a single step in IBM Schematics GUI of the VSI provisioning and the **SAP Netweaver on HANA DB Stack** installation.
- Ansible scripts to configure SAP Netweaver primary application server and a HANA 2.0 node.
Please note that Ansible is started by Terraform and must be available on the same host.


### IBM Cloud API Key
The IBM Cloud API Key should be provided as input value of type sensitive for "IBMCLOUD_API_KEY" variable, in `IBM Schematics -> Workspaces -> <Workspace name> -> Settings` menu.
The IBM Cloud API Key can be created [here](https://cloud.ibm.com/iam/apikeys).

### Input parameters
The following parameters can be set in the Schematics workspace: VPC, Subnet, Security group, Resource group, Hostname, Profile, Image, SSH Keys, Activity Tracker variables, and your SAP system configuration variables, as below:

**VSI input parameters:**

Parameter | Description
----------|------------
IBMCLOUD_API_KEY | IBM Cloud API key (Sensitive* value).
ID_RSA_FILE_PATH | The file path for PRIVATE_SSH_KEY will be automatically generated by default. If it is changed, it must contain the relative path from git repo folders.<br /> Default value: "ansible/id_rsa".
PRIVATE_SSH_KEY | Input your id_rsa private key pair content in OpenSSH format (Sensitive* value). This private key should be used only during the terraform provisioning and it is recommended to be changed after the SAP deployment.
SSH_KEYS | List of SSH Keys UUIDs that are allowed to SSH as root to the VSI. Can contain one or more IDs. The list of SSH Keys is available [here](https://cloud.ibm.com/vpc-ext/compute/sshKeys). <br /> Sample input (use your own SSH UUIDs from IBM Cloud):<br /> [ "r010-57bfc315-f9e5-46bf-bf61-d87a24a9ce7a" , "r010-3fcd9fe7-d4a7-41ce-8bb3-d96e936b2c7e" ]
BASTION_FLOATING_IP | The FLOATING IP from the Bastion Server.
RESOURCE_GROUP | The name of an EXISTING Resource Group for VSIs and Volumes resources.  <br /> Default value: "Default". The list of Resource Groups is available [here](https://cloud.ibm.com/account/resource-groups).
REGION | The cloud region where to deploy the solution. <br /> The regions and zones for VPC are listed [here](https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc). <br /> Review supported locations in IBM Cloud Schematics [here](https://cloud.ibm.com/docs/schematics?topic=schematics-locations).<br /> Sample value: eu-de.
ZONE | The cloud zone where to deploy the solution. <br /> Sample value: eu-de-2.
VPC | The name of an EXISTING VPC. The list of VPCs is available [here](https://cloud.ibm.com/vpc-ext/network/vpcs)
SUBNET | The name of an EXISTING Subnet. The list of Subnets is available [here](https://cloud.ibm.com/vpc-ext/network/subnets). 
SECURITY_GROUP | The name of an EXISTING Security group. The list of Security Groups is available [here](https://cloud.ibm.com/vpc-ext/network/securityGroups). 
DB_HOSTNAME | The Hostname for the HANA VSI. The hostname should be up to 13 characters as required by SAP.  For more information on rules regarding hostnames for SAP systems, check [SAP Note 611361: Hostnames of SAP ABAP Platform servers](https://launchpad.support.sap.com/#/notes/%20611361)
DB_PROFILE | The instance profile used for the HANA VSI. The list of certified profiles for HANA VSIs is available [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc). <br> Details about all x86 instance profiles are available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles). <br>  For more information about supported DB/OS and IBM Gen 2 Virtual Server Instances (VSI), check [SAP Note 2927211: SAP Applications on IBM Virtual Private Cloud](https://launchpad.support.sap.com/#/notes/2927211) <br /> Default value: "mx2-16x128"
DB_IMAGE | The OS image used for HANA VSI (See Obs*). A list of images is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-about-images).<br /> Default value: ibm-redhat-8-6-amd64-sap-hana-4
APP_HOSTNAME | The Hostname for the SAP Application VSI. The hostname should be up to 13 characters as required by SAP.  For more information on rules regarding hostnames for SAP systems, check [SAP Note 611361: Hostnames of SAP ABAP Platform servers](https://launchpad.support.sap.com/#/notes/%20611361)
APP_PROFILE |  The instance profile used for SAP Application VSI. A list of profiles is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles) <br>  For more information about supported DB/OS and IBM Gen 2 Virtual Server Instances (VSI), check [SAP Note 2927211: SAP Applications on IBM Virtual Private Cloud](https://launchpad.support.sap.com/#/notes/2927211) <br /> Default value: "bx2-4x16"
APP_IMAGE | The OS image used for SAP Application VSI (See Obs*). A list of images is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-about-images).<br /> Default value: ibm-redhat-8-6-amd64-sap-applications-4

**Activity Tracker input parameters:**

Parameter | Description
----------|------------
ATR_NAME | The name of the EXISTING Activity Tracker instance, in the same region chosen for SAP system deployment. The list of available Activity Tracker is available [here](https://cloud.ibm.com/observe/activitytracker)

**SAP input parameters:**

Parameter | Description | Requirements
----------|-------------|-------------
HANA_SID | The SAP system ID identifies the SAP HANA system.<br /> _(See Obs.*)_ | <ul><li>Consists of exactly three alphanumeric characters</li><li>Has a letter for the first character</li><li>Does not include any of the reserved IDs listed in SAP Note 1979280</li></ul>|
HANA_SYSNO | Specifies the instance number of the SAP HANA system| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
HANA_MAIN_PASSWORD | Common password for all users that are created during the installation. _(See Obs.*)_ | <ul><li>It must be 8 to 14 characters long</li><li>It must consist of at least one digit (0-9), one lowercase letter (a-z), and one uppercase letter (A-Z).</li><li>It can only contain the following characters: a-z, A-Z, 0-9, !, @, #, $, _</li><li>It must not start with a digit or an underscore ( _ )</li></ul> <br /> (Sensitive* value)
HANA_SYSTEM_USAGE  | System Usage | Default: custom<br> Valid values: production, test, development, custom
HANA_COMPONENTS | SAP HANA Components | Default: server<br> Valid values: all, client, es, ets, lcapps, server, smartda, streaming, rdsync, xs, studio, afl, sca, sop, eml, rme, rtl, trp
KIT_SAPHANA_FILE | Path to SAP HANA ZIP file.<br /> _(See Obs.*)_ | As downloaded from SAP Support Portal.<br /> Default: /storage/HANADB/51055299.ZIP
SAP_SID | The SAP system ID <SAPSID> identifies the entire SAP system.<br /> _(See Obs.*)_ | <ul><li>Consists of exactly three alphanumeric characters</li><li>Has a letter for the first character</li><li>Does not include any of the reserved IDs listed in SAP Note 1979280</li></ul>
SAP_ASCS_INSTANCE_NUMBER | Technical identifier for internal processes of ASCS| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
SAP_CI_INSTANCE_NUMBER | Technical identifier for internal processes of CI| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
SAP_MAIN_PASSWORD | Common password for all users that are created during the installation.<br /> _(See Obs.*)_ | <ul><li>It must be 10 to 14 characters long</li><li>It must contain at least one digit (0-9)</li><li>It can only contain the following characters: a-z, A-Z, 0-9, @, #, $, _</li><li>It must not start with a digit or an underscore ( _ )</li></ul> <br /> (Sensitive* value)
HDB_CONCURRENT_JOBS | Number of concurrent jobs used to load and/or extract archives to HANA Host | Default: 23
KIT_SAPCAR_FILE  | Path to sapcar binary | As downloaded from SAP Support Portal.<br /> Default: /storage/NW75HDB/SAPCAR_1010-70006178.EXE
KIT_SWPM_FILE | Path to SWPM archive (SAR) | As downloaded from SAP Support Portal.<br /> Default: /storage/NW75HDB/SWPM10SP31_7-20009701.SAR
KIT_SAPEXE_FILE | Path to SAP Kernel OS archive (SAR) | As downloaded from SAP Support Portal.<br /> Default: /storage/NW75HDB/SAPEXE_801-80002573.SAR
KIT_SAPEXEDB_FILE | Path to SAP Kernel DB archive (SAR) | As downloaded from SAP Support Portal.<br /> Default: /storage/NW75HDB/SAPEXEDB_801-80002572.SAR
KIT_IGSEXE_FILE | Path to IGS archive (SAR) | As downloaded from SAP Support Portal.<br /> Default: /storage/NW75HDB/igsexe_13-80003187.sar
KIT_IGSHELPER_FILE | Path to IGS Helper archive (SAR) | As downloaded from SAP Support Portal.<br /> Default: /storage/NW75HDB/igshelper_17-10010245.sar
KIT_SAPHOSTAGENT_FILE | Path to SAP Host Agent archive (SAR) | As downloaded from SAP Support Portal. <br /> Default: /storage/NW75HDB/SAPHOSTAGENT51_51-20009394.SAR
KIT_HDBCLIENT_FILE | Path to HANA DB client archive (SAR) | As downloaded from SAP Support Portal.<br /> Default: /storage/NW75HDB/IMDB_CLIENT20_009_28-80002082.SAR
KIT_NWHANA_EXPORT | Path to Netweaver Installation Export dir | The archives downloaded from SAP Support Portal should be present in this path.<br /> Default: /storage/NW75HDB/ABAPEXP

**Obs***: <br />
 - **SAP/HANA Passwords.**
The passwords for the SAP system will be hidden during the schematics apply step and will not be available after the deployment.

- **Sensitive** - The variable value is not displayed in your Schematics logs and it is hidden in the input field.<br />
- The following parameters should have the same values as the ones set for the BASTION server: REGION, ZONE, VPC, SUBNET, SECURITYGROUP.
- For any manual change in the terraform code, you have to make sure that you use a certified image based on the SAP NOTE: 2927211.
- OS **image** for **DB VSI.** Supported OS images for DB VSIs: ibm-sles-15-4-amd64-sap-hana-5, ibm-sles-15-3-amd64-sap-hana-8, ibm-redhat-8-6-amd64-sap-hana-4, ibm-redhat-8-4-amd64-sap-hana-7.
    - The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
    - Default variable:  DB-IMAGE = "ibm-redhat-8-6-amd64-sap-hana-4"
- OS **image** for **SAP APP VSI**. Supported OS images for APP VSIs: ibm-sles-15-3-amd64-sap-applications-9, ibm-sles-15-4-amd64-sap-applications-6, ibm-redhat-8-4-amd64-sap-applications-7, ibm-redhat-8-6-amd64-sap-applications-4. 
    - The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
    - Default variable: APP-IMAGE = "ibm-redhat-8-6-amd64-sap-applications-4"
-  SAP **HANA Installation path kit**
     - Supported SAP HANA versions on Red Hat 8.4, 8.6 and Suse 15.3, 15.4: HANA 2.0 SP 5 Rev 57, kit file: 51055299.ZIP
     - Example for Red Hat 8 or Suse 15: KIT_SAPHANA_FILE = "/storage/HANADB/51055299.ZIP"
     - Default variable:  KIT_SAPHANA_FILE = "/storage/HANADB/51055299.ZIP"
- The following SAP **"_SID_"** values are _reserved_ and are _not allowed_ to be used: ADD, ALL, AMD, AND, ANY, ARE, ASC, AUX, AVG, BIT, CDC, COM, CON, DBA, END, EPS, FOR, GET, GID, IBM, INT, KEY, LOG, LPT, MAP, MAX, MIN, MON, NIX, NOT, NUL, OFF, OLD, OMS, OUT, PAD, PRN, RAW, REF, ROW, SAP, SET, SGA, SHG, SID, SQL, SUM, SYS, TMP, TOP, UID, USE, USR, VAR.

### Steps to follow:

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
    select [Schematics](https://cloud.ibm.com/schematics/overview).
        - Push the `Create workspace` button.
        - Provide the URL of the Github repository of this solution
        - Select the latest Terraform version.
        - Click on `Next` button
        - Provide a name, the resources group and location for your workspace
        - Push `Next` button
        - Review the provided information and then push `Create` button to create your workspace
    2.  On the workspace **Settings** page, 
        - In the **Input variables** section, review the default values for the input variables and provide alternatives if desired.
        - Click **Save changes**.
4.  From the workspace **Settings** page, click **Generate plan** 
5.  From the workspace **Jobs** page, the logs of your Terraform
    execution plan can be reviewed.
6.  Apply your Terraform template by clicking **Apply plan**.
7.  Review the logs to ensure that no errors occurred during the
    provisioning, modification, or deletion process.

    In the output of the Schematics `Apply Plan` the private IP address of the VSI hosts, the hostname of the VSIs and the activity tracker instance name will be displayed.

## 2.3 Executing the deployment of **SAP Netweaver on HANA DB Stack** in CLI

The solution is based on Terraform scripts and Ansible playbooks executed in CLI and it is implementing a 'reasonable' set of best practices for SAP VSI host configuration.

**It contains:**
- Terraform scripts for the deployment of two VSIs, in an EXISTING VPC, with Subnet and Security Group. The VSIs are intended to be used: one for the data base instance and the other for the application instance. The automation has support for the following versions: Terraform >= 1.5.7 and IBM Cloud provider for Terraform >= 1.57.0.  Note: The deployment was tested with Terraform 1.5.7
- Ansible scripts to configure SAP Netweaver primary application server and a HANA 2.0 node.
Please note that Ansible is started by Terraform and must be available on the same host.

### IBM Cloud API Key
For the script configuration add your IBM Cloud API Key in terraform planning phase command 'terraform plan --out plan1'.
You can create an API Key [here](https://cloud.ibm.com/iam/apikeys).

### Input parameter file
The solution is configured by editing your variables in the file `input.auto.tfvars`
Edit your VPC, Subnet, Security group, Hostname, Profile, Image, SSH Keys and starting with minimal recommended disk sizes like so:

**VSI input parameters**

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
# Input your id_rsa private key file path in OpenSSH format with 0600 permissions.
# This private key it is used only during the terraform provisioning and it is recommended to be changed after the SAP deployment.
# Can be used relative or absolut paths. Examples: "~/.ssh/id_rsa_nw_abap_hana" or "/root/.ssh/id_rsa".

##########################################################
# SAP Database VSI variables:
##########################################################

DB_HOSTNAME = "sapnwhdb" 
# The hostname for the DB VSI. The hostname should be up to 13 characters, as required by SAP
# Example: DB_HOSTNAME = "sapnwhdb"

DB_PROFILE = "mx2-16x128"
# The DB VSI profile. Supported profiles for DB VSI: mx2-16x128. The list of available profiles: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui

DB_IMAGE = "ibm-redhat-8-6-amd64-sap-hana-4"
# OS image for HANA DB VSI. Supported OS images for HANA DB VSIs: ibm-redhat-8-4-amd64-sap-hana-7, ibm-redhat-8-6-amd64-sap-hana-4,ibm-sles-15-3-amd64-sap-hana-8, ibm-sles-15-4-amd64-sap-hana-5.
# The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
# Example: IMAGE = "ibm-redhat-8-6-amd64-sap-hana-4"

##########################################################
# SAP APPs VSI variables
##########################################################

APP_HOSTNAME = "sapnwci" 
# The hostname for the APP VSI. The hostname should be up to 13 characters, as required by SAP
# Example: APP_HOSTNAME = "sapnwci"

APP_PROFILE = "bx2-4x16"
# The APP VSI profile. Supported profiles for DB VSI: bx2-4x16. The list of available profiles: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui

APP_IMAGE = "ibm-redhat-8-6-amd64-sap-applications-4"
# OS image for SAP APP VSI. Supported OS images for SAP APP VSIs: ibm-redhat-8-4-amd64-sap-applications-7, ibm-redhat-8-6-amd64-sap-applications-2, ibm-sles-15-3-amd64-sap-applications-9, ibm-sles-15-4-amd64-sap-applications-6.
# The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
# Example: IMAGE = "ibm-redhat-8-6-amd64-sap-applications-4"

```

Parameter | Description
----------|------------
IBMCLOUD_API_KEY | IBM Cloud API key (Sensitive* value).
REGION | The cloud region where to deploy the solution. <br /> The regions and zones for VPC are listed [here](https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc). <br />  Sample value: eu-de.
ZONE | The cloud zone where to deploy the solution. <br /> Sample value: eu-de-2.
VPC | The name of an EXISTING VPC. The list of VPCs is available [here](https://cloud.ibm.com/vpc-ext/network/vpcs)
SECURITY_GROUP | The name of an EXISTING Security group. The list of Security Groups is available [here](https://cloud.ibm.com/vpc-ext/network/securityGroups). 
RESOURCE_GROUP | The name of an EXISTING Resource Group for VSIs and Volumes resources. <br /> Sample value: "Default". The list of Resource Groups is available [here](https://cloud.ibm.com/account/resource-groups).
SUBNET | The name of an EXISTING Subnet. The list of Subnets is available [here](https://cloud.ibm.com/vpc-ext/network/subnets). 
SSH_KEYS | List of SSH Keys UUIDs that are allowed to SSH as root to the VSI. Can contain one or more IDs. The list of SSH Keys is available [here](https://cloud.ibm.com/vpc-ext/compute/sshKeys). <br /> Sample input (use your own SSH UUIDs from IBM Cloud):<br /> [ "r010-57bfc315-f9e5-46bf-bf61-d87a24a9ce7a" , "r010-3fcd9fe7-d4a7-41ce-8bb3-d96e936b2c7e" ]
ID_RSA_FILE_PATH | The file path for PRIVATE_SSH_KEY will be automatically generated by default. If it is changed, it must contain the relative path from git repo folders.<br /> Sample value: "ansible/id_rsa_nw_abap_hana".
DB_HOSTNAME | The Hostname for the HANA VSI. The hostname should be up to 13 characters as required by SAP.  For more information on rules regarding hostnames for SAP systems, check [SAP Note 611361: Hostnames of SAP ABAP Platform servers](https://launchpad.support.sap.com/#/notes/%20611361)
DB_PROFILE |  The instance profile used for the HANA VSI. A list of profiles is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles) <br>  For more information about supported DB/OS and IBM Gen 2 Virtual Server Instances (VSI), check [SAP Note 2927211: SAP Applications on IBM Virtual Private Cloud](https://launchpad.support.sap.com/#/notes/2927211) <br /> Default value: "mx2-16x128"
DB_IMAGE | The OS image used for HANA VSI (See Obs*). A list of images is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-about-images).<br /> Default value: ibm-redhat-8-6-amd64-sap-hana-4
APP-HOSTNAME | The Hostname for the SAP Application VSI. The hostname should be up to 13 characters as required by SAP.  For more information on rules regarding hostnames for SAP systems, check [SAP Note 611361: Hostnames of SAP ABAP Platform servers](https://launchpad.support.sap.com/#/notes/%20611361)
APP-PROFILE |  The instance profile used for SAP Application VSI. A list of profiles is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles) <br>  For more information about supported DB/OS and IBM Gen 2 Virtual Server Instances (VSI), check [SAP Note 2927211: SAP Applications on IBM Virtual Private Cloud](https://launchpad.support.sap.com/#/notes/2927211) <br /> Default value: "bx2-4x16"
APP-IMAGE | The OS image used for SAP Application VSI (See Obs*). A list of images is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-about-images).<br /> Default value: ibm-redhat-8-6-amd64-sap-applications-4


**Activity Tracker input parameters**

Edit your IBM Cloud Activity Tracker input variables below:

```shell
##########################################################
# Activity Tracker variables:
##########################################################

ATR_NAME = "Activity-Tracker-SAP-eu-de"
# The name of the EXISTING Activity Tracker instance, in the same region chosen for SAP system deployment.
# Example: ATR_NAME="Activity-Tracker-SAP-eu-de"

```

Parameter | Description
----------|------------
ATR_NAME | The name of the EXISTING Activity Tracker instance, in the same region chosen for SAP system deployment. The list of available Activity Tracker is available [here](https://cloud.ibm.com/observe/activitytracker)

Edit the SAP system configuration variables that will be passed to the ansible automated deployment:

```shell

##########################################################
# HANA DB configuration
##########################################################

HANA_SID = "HDB"
HANA_SYSNO = "00"
HANA_SYSTEM_USAGE = "custom"
HANA_COMPONENTS = "server"


##########################################################
# SAP HANA Installation kit path
##########################################################
KIT_SAPHANA_FILE = "/storage/HANADB/51055299.ZIP"


##########################################################
# SAP system configuration
##########################################################

SAP_SID = "NWD"
# SAP System ID

SAP_ASCS_INSTANCE_NUMBER = "01"
# The central ABAP service instance number. Should follow the SAP rules for instance number naming.
# Example: SAP_ASCS_INSTANCE_NUMBER = "01"

SAP_CI_INSTANCE_NUMBER = "00"
# The SAP central instance number. Should follow the SAP rules for instance number naming.
# Example: SAP_ASCS_INSTANCE_NUMBER = "06"

# Number of concurrent jobs used to load and/or extract archives to HANA Host
HDB_CONCURRENT_JOBS = "12"

##########################################################
# SAP NW APP Installation kit path
##########################################################

KIT_SAPCAR_FILE = "/storage/NW75HDB/SAPCAR_1010-70006178.EXE"
KIT_SWPM_FILE = "/storage/NW75HDB/SWPM10SP31_7-20009701.SAR"
KIT_SAPEXE_FILE = "/storage/NW75HDB/SAPEXE_801-80002573.SAR"
KIT_SAPEXEDB_FILE = "/storage/NW75HDB/SAPEXEDB_801-80002572.SAR"
KIT_IGSEXE_FILE = "/storage/NW75HDB/igsexe_13-80003187.sar"
KIT_IGSHELPER_FILE = "/storage/NW75HDB/igshelper_17-10010245.sar"
KIT_SAPHOSTAGENT_FILE = "/storage/NW75HDB/SAPHOSTAGENT51_51-20009394.SAR"
KIT_HDBCLIENT_FILE = "/storage/NW75HDB/IMDB_CLIENT20_009_28-80002082.SAR"
KIT_NWHANA_EXPORT = "/storage/NW75HDB/ABAPEXP"
```
**SAP input parameters:**

Parameter | Description | Requirements
----------|-------------|-------------
HANA_SID | The SAP system ID identifies the SAP HANA system | <ul><li>Consists of exactly three alphanumeric characters</li><li>Has a letter for the first character</li><li>Does not include any of the reserved IDs listed in SAP Note 1979280</li></ul>|
HANA_SYSNO | Specifies the instance number of the SAP HANA system| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
HANA_SYSTEM_USAGE  | System Usage | Default: custom<br> Valid values: production, test, development, custom
HANA_COMPONENTS | SAP HANA Components | Default: server<br> Valid values: all, client, es, ets, lcapps, server, smartda, streaming, rdsync, xs, studio, afl, sca, sop, eml, rme, rtl, trp
KIT_SAPHANA_FILE | Path to SAP HANA ZIP file | As downloaded from SAP Support Portal
SAP_SID | The SAP system ID <SAPSID> identifies the entire SAP system | <ul><li>Consists of exactly three alphanumeric characters</li><li>Has a letter for the first character</li><li>Does not include any of the reserved IDs listed in SAP Note 1979280</li></ul>
SAP_ASCS_INSTANCE_NUMBER | Technical identifier for internal processes of ASCS| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
SAP_CI_INSTANCE_NUMBER | Technical identifier for internal processes of CI| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
HDB_CONCURRENT_JOBS | Number of concurrent jobs used to load and/or extract archives to HANA Host | Default: 12
KIT_SAPCAR_FILE  | Path to sapcar binary | As downloaded from SAP Support Portal
KIT_SWPM_FILE | Path to SWPM archive (SAR) | As downloaded from SAP Support Portal
KIT_SAPEXE_FILE | Path to SAP Kernel OS archive (SAR) | As downloaded from SAP Support Portal
KIT_SAPEXEDB_FILE | Path to SAP Kernel DB archive (SAR) | As downloaded from SAP Support Portal
KIT_IGSEXE_FILE | Path to IGS archive (SAR) | As downloaded from SAP Support Portal
KIT_IGSHELPER_FILE | Path to IGS Helper archive (SAR) | As downloaded from SAP Support Portal
KIT_SAPHOSTAGENT_FILE | Path to SAP Host Agent archive (SAR) | As downloaded from SAP Support Portal
KIT_HDBCLIENT_FILE | Path to HANA DB client archive (SAR) | As downloaded from SAP Support Portal
KIT_NWHANA_EXPORT | Path to Netweaver Installation Export dir | The archives downloaded from SAP Support Portal should be present in this path

**SAP Main Password**
The password for the SAP system will be asked interactively during terraform plan step and will not be available after the deployment.

Parameter | Description | Requirements
----------|-------------|-------------
SAP_MAIN_PASSWORD | Common password for all users that are created during the installation | <ul><li>It must be 8 to 14 characters long</li><li>It must contain at least one digit (0-9)</li><li>It must not contain \ (backslash) and " (double quote)</li></ul>
HANA_MAIN_PASSWORD | HANA system main password | <ul><li>It must be 8 to 14 characters long</li><li>It must contain at least one digit (0-9)</li><li>It must not contain \ (backslash) and " (double quote)</li><li>Main Password must contain at least one upper-case character</li></ul>
 
 

### Steps to follow:

For initializing terraform:

```shell
terraform init
```

For planning phase:

```shell
terraform plan --out plan1
# you will be asked for the following sensitive variables: 'IBMCLOUD_API_KEY', 'SAP_MAIN_PASSWORD' and 'HANA_MAIN_PASSWORD'.
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
- [IBM Cloud Activity Tracker](https://cloud.ibm.com/docs/activity-tracker?topic=activity-tracker-getting-started#gs_ov)
