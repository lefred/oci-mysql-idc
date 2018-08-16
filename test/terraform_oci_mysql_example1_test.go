package test

import (
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/test-structure"

	"terraform-module-test-lib"
)

func TestModuleMysqlExample1(t *testing.T) {
	terraform_dir := "../examples/example-1"
	terraform_options := configureTerraformOption(t, terraform_dir)

	test_structure.RunTestStage(t, "init", func() {
		logger.Log(t, "terraform init ...")
		terraform.Init(t, terraform_options)
	})

	test_structure.RunTestStage(t, "apply", func() {
		logger.Log(t, "terraform apply instance ...")
		terraform.Apply(t, terraform_options)
	})

	test_structure.RunTestStage(t, "validate", func() {
		logger.Log(t, "Verfiying  ...")
		validateSolution(t, terraform_options)
	})

	defer test_structure.RunTestStage(t, "destroy", func() {
		logger.Log(t, "terraform destroy instance ...")
		terraform.Destroy(t, terraform_options)
	})
}

func configureTerraformOption(t *testing.T, terraform_dir string) *terraform.Options {
	var vars Inputs
	err := test_helper.GetConfig("inputs_config.json", &vars)
	if err != nil {
		logger.Logf(t, err.Error())
		t.Fail()
	}
	terraformOptions := &terraform.Options{
		TerraformDir: terraform_dir,
		Vars: map[string]interface{}{
			"tenancy_ocid":                     vars.Tenancy_ocid,
			"user_ocid":                        vars.User_ocid,
			"fingerprint":                      vars.Fingerprint,
			"region":                           vars.Region,
			"compartment_ocid":                 vars.Compartment_ocid,
			"private_key_path":                 vars.Private_key_path,
			"ssh_authorized_keys":              vars.Ssh_authorized_keys,
			"ssh_private_key":                  vars.Ssh_private_key,
			"master_mysql_root_password":       vars.Master_mysql_root_password,
			"slaves_mysql_root_password":       vars.Slaves_mysql_root_password,
			"master_slaves_replicate_acount":   vars.Master_slaves_replicate_acount,
			"master_slaves_replicate_password": vars.Master_slaves_replicate_password,
		},
	}
	return terraformOptions
}

func validateSolutions(t *testing.T, terraform_options *terraform.Options) {
	// build key pair for ssh connections
	ssh_public_key_path := terraform_options.Vars["ssh_authorized_keys"].(string)
	ssh_private_key_path := terraform_options.Vars["ssh_private_key"].(string)
	key_pair, err := test_helper.GetKeyPairFromFiles(ssh_public_key_path, ssh_private_key_path)
	if err != nil {
		assert.NotNil(t, key_pair)
	}
	validateBySSHToMysqlMasterHost(t, terraform_options, key_pair)
	validateBySSHToMysqlSlaveHost(t, terraform_options, key_pair)

	resource_name := "module.instance.oci_core_instance.this"
	validateByStates(t, terraform_options, resource_name)
}

func validateBySSHToMysqlMasterHost(t *testing.T, terraform_options *terraform.Options, key_pair *ssh.KeyPair) {
	rootpassword := terraform_options.Vars["master_mysql_root_password"].(string)
	replicationAccount := terraform_options.Vars["master_slaves_replicate_acount"].(string)
	command := "mysql -u root -p" + rootpassword + " -e " + "\"show grants for '" + replicationAccount + "'@'%';\""
	master_public_ip := terraform.Output(t, terraform_options, "master_public_ip")
	result := test_helper.SSHToHost(t, master_public_ip, "opc", key_pair, command)
	assert.True(t, strings.Contains(result, "GRANT REPLICATION SLAVE ON *.* TO `repl`@`%`"))
}

func validateBySSHToMysqlSlaveHost(t *testing.T, terraform_options *terraform.Options, key_pair *ssh.KeyPair) {
	//replicationAccount := terraform_options.Vars["master_slaves_replicate_acount"].(string)
	//replicationPassword := terraform_options.Vars["master_slaves_replicate_password"].(string)

	password := terraform_options.Vars["slaves_mysql_root_password"].(string)

	command := "mysql -u root -p" + password + " -e " + "\"show slave status \\G;\""
	slave_public_ips := terraform.Output(t, terraform_options, "slave_public_ip")
	public_ips := strings.Split(slave_public_ips, ",")
	for i := 0; i < len(public_ips); i++ {
		ip := strings.TrimSpace(public_ips[i])
		result := test_helper.SSHToHost(t, ip, "opc", key_pair, command)
		assert.True(t, strings.Contains(result, "Slave_IO_Running: Connecting"))
	}
}

func validateByStates(t *testing.T, terraform_options *terraform.Options, resource_name string) {
	// terraform_command := fmt.Sprintf("state show %s", resource_name)
	display_name := test_helper.GetResourceProperty(t, terraform_options, "display_name", "state", "show", resource_name)
	assert.Equal(t, "tf-mysql-master", display_name)
}
