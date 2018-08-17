## Run go test to test the example in this module
This example shows how to run go test to test a terraform module.

### Using this test example
Update inputs_config.json with the required information.

### Run go test  
Download or update the specified code package and its dependencies from Internet:
```
$ cd test
$ go get
```
Run go test:
```
$ go test -timeout 60m -v -run TestModuleMysqlExample2
```