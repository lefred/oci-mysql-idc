# OCI Authentication details
#tenancy_ocid = "<tenancy OCID>"
#user_ocid = "<user OCID>"
#fingerprint= "<PEM key fingerprint>"
#private_key_path = "<path to the private key that matches the fingerprint above>"

tenancy_ocid = "ocid1.tenancy.oc1..aaaaaaaaej42v3hufhtwz7ssrsynoslc7eunq2nrkepvqjhxj3dbxknnhhwa"

user_ocid = "ocid1.user.oc1..aaaaaaaat2vcfezpxdah2xckxgpannwtuhsl3llqr5gspiiuheuigt5lnevq"

fingerprint = "30:a1:c8:ff:6a:ac:b2:e3:59:e1:59:93:98:c7:ae:d1"

private_key_path = "/Users/yupengshan/tools/OCI/oci_api_key.pem"

# Region
#region = "<region in which to operate, example: us-ashburn-1, us-phoenix-1>"
region = "us-phoenix-1"

# Compartment
#compartment_ocid = "<compartment OCID>"
compartment_ocid = "ocid1.compartment.oc1..aaaaaaaajsuweibqc44mis7dcbdv6zempt55mw76o4wikea3sxblgjovhrya"

#Instance Configration
#ssh_authorized_keys = "<path to public key>"
#ssh_private_key = "<path to private key>"
#master_subnet_id = "<subnet OCID>"
#slave_subnet_ids = ["<list of subnet OCID>"]

ssh_authorized_keys = "/Users/yupengshan/.ssh/id_rsa.pub"

ssh_private_key = "/Users/yupengshan/.ssh/id_rsa"

master_subnet_id = "ocid1.subnet.oc1.phx.aaaaaaaak7gcdbgfu63ubm5aombrjiz4lxijyfyptbml6nurlx7r6hbywmdq"

slave_subnet_ids = ["ocid1.subnet.oc1.phx.aaaaaaaak7gcdbgfu63ubm5aombrjiz4lxijyfyptbml6nurlx7r6hbywmdq", "ocid1.subnet.oc1.phx.aaaaaaaaxfzsvvciz7ocxtompl3jskoaenokffavnwsrbcls6dxvayhbpikq", "ocid1.subnet.oc1.phx.aaaaaaaaya26ajtg3kvb5ksqymaiiks34q7qeefgcnlw2xidjtik47ihwsfa"]

#Set a initial MySQL password for the account 'root@localhost'
#MySQL's validate_password plugin is installed by default.
#This will require that passwords contain at least one upper case letter,
#one lower case letter, one digit, and one special character,
#and that the total password length is at least 8 characters.
master_mysql_root_password = "Admin@123"

slaves_mysql_root_password = "Admin@123"

master_slaves_replicate_acount = "repl"

master_slaves_replicate_password = "Slaves@123"
