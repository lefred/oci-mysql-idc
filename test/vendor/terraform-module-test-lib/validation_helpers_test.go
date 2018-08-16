package test_helper

import (
	"fmt"
	"io/ioutil"
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/stretchr/testify/assert"
)

func TestInvalidPublicKeyPath(t *testing.T) {
	t.Parallel()

	public_key_path := "key.pub"
	content := []byte("private key file content")
	private_key_path := CreateTempFile(t, "private_key", content)
	defer os.Remove(private_key_path)
	key_pair, err := GetKeyPairFromFiles(public_key_path, private_key_path)
	assert.NotNil(t, err)
	assert.True(t, strings.HasPrefix(err.Error(), "Error reading ssh public key file"))
	assert.Nil(t, key_pair)
}

func TestInvalidPrivateKeyPath(t *testing.T) {
	t.Parallel()

	content := []byte("public key file content")
	public_key_path := CreateTempFile(t, "pub_key", content)
	defer os.Remove(public_key_path)
	private_key_path := "keys"
	key_pair, err := GetKeyPairFromFiles(public_key_path, private_key_path)
	assert.NotNil(t, err)
	assert.True(t, strings.HasPrefix(err.Error(), "Error reading ssh private key file"))
	assert.Nil(t, key_pair)
}

func TestValidKeyPaths(t *testing.T) {
	t.Parallel()

	content := []byte("public key file content")
	public_key_path := CreateTempFile(t, "pub_key", content)
	defer os.Remove(public_key_path)
	content = []byte("private key file content")
	private_key_path := CreateTempFile(t, "private_key", content)
	defer os.Remove(private_key_path)
	key_pair, err := GetKeyPairFromFiles(public_key_path, private_key_path)
	assert.Nil(t, err)
	assert.NotNil(t, key_pair)
}

func TestHTTPGet(t *testing.T) {
	t.Parallel()

	unique_id := random.UniqueId()
	txt := fmt.Sprintf("test-server-%s", unique_id)
	listener, port := http_helper.RunDummyServer(t, txt)
	defer listener.Close()
	url := fmt.Sprintf("http://localhost:%d", port)

	HTTPGetWithStatusValidation(t, url, 200)
	HTTPGetWithBodyValidation(t, url, txt)
}

func TestCreateTempFile(t *testing.T) {
	t.Parallel()

	txt := []byte("test temp file")
	temp_file := CreateTempFile(t, "test", txt)
	defer os.Remove(temp_file)
	content, err := ioutil.ReadFile(temp_file)
	assert.Nil(t, err)
	assert.Equal(t, content, txt)
}

func TestGenerateSSHKeyFilesFromKeyPair(t *testing.T) {
	t.Parallel()

	key_pair := ssh.GenerateRSAKeyPair(t, 2048)
	public_key_path, private_key_path := GenerateSSHKeyFilesFromKeyPair(t, key_pair)
	defer os.Remove(public_key_path)
	defer os.Remove(private_key_path)
	public_key, err := ioutil.ReadFile(public_key_path)
	assert.Nil(t, err)
	private_key, err := ioutil.ReadFile(private_key_path)
	assert.Nil(t, err)
	assert.Contains(t, string(public_key), "ssh-rsa")
	assert.Contains(t, string(private_key), "-----BEGIN RSA PRIVATE KEY-----")
}

func TestGetConfig(t *testing.T) {
	t.Parallel()

	type Inputs struct {
		String_value  string   `json:"string_value"`
		Int_value     int      `json:"int_value"`
		Boolean_value bool     `json:"boolean_value"`
		List_value    []string `json:"list_value"`
	}
	var inputs Inputs
	err := GetConfig("inputs_config.json", &inputs)
	assert.Nil(t, err)
	assert.NotNil(t, inputs)
	assert.Equal(t, "string value", inputs.String_value)
	assert.Equal(t, 99, inputs.Int_value)
	assert.Equal(t, true, inputs.Boolean_value)
	assert.Equal(t, 2, len(inputs.List_value))
	assert.Equal(t, "string 1", inputs.List_value[0])
	assert.Equal(t, "string 2", inputs.List_value[1])

}
