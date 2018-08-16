package test

type Inputs struct {
	Tenancy_ocid                     string `json:"tenancy_ocid"`
	Compartment_ocid                 string `json:"compartment_ocid"`
	User_ocid                        string `json:"user_ocid"`
	Region                           string `json:"region"`
	Fingerprint                      string `json:"fingerprint"`
	Private_key_path                 string `json:"private_key_path"`
	Ssh_authorized_keys              string `json:"ssh_authorized_keys"`
	Ssh_private_key                  string `json:"ssh_private_key"`
	Master_mysql_root_password       string `json:"master_mysql_root_password"`
	Slaves_mysql_root_password       string `json:"slaves_mysql_root_password"`
	Master_slaves_replicate_acount   string `json:"master_slaves_replicate_acount"`
	Master_slaves_replicate_password string `json:"master_slaves_replicate_password"`
}
