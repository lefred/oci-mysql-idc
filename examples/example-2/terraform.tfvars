# OCI Authentication details
#tenancy_ocid = "<tenancy OCID>"

#user_ocid = "<user OCID>"

#fingerprint = "<PEM key fingerprint>"

#private_key_path = "<path to the private key that matches the fingerprint above>"

tenancy_ocid = "ocid1.tenancy.oc1..aaaaaaaawgbzspd6cjovpmic7dahwbalg4opcbixgguo6z2s7t335m6lalbq"

user_ocid = "ocid1.user.oc1..aaaaaaaazys5dvasatetxcee4t5teo2cttsjhpnws7qrldctqt375mlqvelq"

fingerprint = "d3:45:3e:1f:e8:79:2b:1d:03:07:3a:2f:c2:99:1e:a2"

private_key_path = "/Users/yupengshan/tools/OCI/oci_api_key.pem"

# Region
#region = "<region in which to operate, example: us-ashburn-1, us-phoenix-1>"
region = "us-phoenix-1"

# Compartment
#compartment_ocid = "<compartment OCID>"
compartment_ocid = "ocid1.compartment.oc1..aaaaaaaawzlfllc7kkf62dzkes75urrxfxppz5fjphx27a7k5fk5jnzvyhiq"

#Instance Configration
#ssh_authorized_keys = "<path to public key>"

#ssh_private_key = "<path to private key>"

ssh_authorized_keys = "/Users/yupengshan/.ssh/id_rsa.pub"

ssh_private_key = "/Users/yupengshan/.ssh/id_rsa"

master_subnet_id = "ocid1.subnet.oc1.phx.aaaaaaaamdrtxxug7qv72cbwqhbw3sle3axq6irj26xapcg2fix7gsum6xoa"

slave_subnet_ids = ["ocid1.subnet.oc1.phx.aaaaaaaamdrtxxug7qv72cbwqhbw3sle3axq6irj26xapcg2fix7gsum6xoa", "ocid1.subnet.oc1.phx.aaaaaaaaaqvypodhwi5zpfspmuvu6s2sm2yzjy4fpzo4jau4vnzzwjh3476a", "ocid1.subnet.oc1.phx.aaaaaaaaats3obrnczlkkbnvhwzy6qc425iqo3mybvmh4eaikmw5r74ng35a"]

#Set a initial MySQL password for the account 'root@localhost'
#MySQL's validate_password plugin is installed by default.
#This will require that passwords contain at least one upper case letter,
#one lower case letter, one digit, and one special character,
#and that the total password length is at least 8 characters.
master_mysql_root_password = "Admin@123"

slaves_mysql_root_password = "Admin@123"

master_slaves_replicate_acount = "repl"

master_slaves_replicate_password = "Slaves@123"
