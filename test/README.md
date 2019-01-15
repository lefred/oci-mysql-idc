## Test Oracle Cloud Infrastructure MySQL Terraform Module
1.Install Terraform and make sure it's on your PATH.

2.Install Golang and make sure this code is checked out into your GOPATH.

3.cd test

4.go test -v -run TestTerraformMysqlDeployExample

Note:

Go's package testing has a default timeout of 10 minutes, after which it forcibly kills your tests (even your cleanup code won't run!). It's not uncommon for infrastructure tests to take longer than 10 minutes, so you'll want to increase this timeout:

go test -v -run TestTerraformMysqlDeployExample -timeout 30m
