# bash-firefighter

Curated list of useful bash techniques

## Table of Contents

- [Helper](#user-content-helper)
- [Generic](#user-content-generic)
- [Programming](#user-content-programming)
  - [Array](#user-content-array)
  - [Join](#user-content-join-method)
  - [Variables](#user-content-variables)
  - [Split](#user-content-split-method)
  - [Regex](#user-content-regex)
  - [Modules](#user-content-modules)
  - [Function in Function](#user-content-function-in-function)
- [Config Files](#user-content-config-files)
  - [Convert YAML to key=value](#user-content-yaml)
- [Cloud Provider](#user-content-cloud-provider)
  - [AWS](#user-content-aws)

## <a name="user-content-helper"></a>Helper

- yq, refer to [install_yq.sh](./scripts/install_yq.sh). Or [other ways](https://mikefarah.gitbook.io/yq/#on-ubuntu-16-04-or-higher-from-debian-package)
- jq, refer to [install_jq.sh](./scripts/install_jq.sh)
- Get local directory of script [local_dir.sh](./scripts/local_dir.sh)
- Get OS platform [get_os.sh](./scripts/get_os.sh)

## <a name="user-content-generic"></a>Generic

### <a name="user-content-exit-on-error"></a>Exit on error

```sh
#!/bin/bash
set -e
```

### <a name="user-content-retry-on-error"></a>Retry on error

- Refer to [retry.sh](./scripts/retry.sh)

### <a name="user-content-user-continue"></a>User Continue

- Refer to [user_continue.sh](./scripts/user_continue.sh)

## <a name="user-content-programming"></a>Programming

### <a name="user-content-array"></a>Array

Loop through indices, values

```sh
for i in "${!foo[@]}"; do
  echo "${i}: ${foo[$i]}"
done
```

Loop through values

```sh
for i in "${foo[@]}"; do
  echo "${i}"
done
```

### <a name="user-content-join-method"></a>Join method

Join array to string

```sh
foo_arr=['a','b','c']
bar=$(IFS=. ; echo "${foo_arr[*]}")

# a.b.c
```

### <a name="user-content-variables"></a>Variables

Declare local variable

```sh
function foo() {
  local bar=""
}

foo
# only work with function
```

Declare global variable

```sh
bar=""

function foo() {
  echo "${bar}"
}
```

Default value

```sh
bar="${1:-default}"

echo "${bar}"
# default
```

### <a name="user-content-split-method"></a>Split method

Split string to array

```sh
IFS='.' read -ra arr <<< "a.b.c"

echo "${arr[@]}
# ['a', 'b', 'c']
```

### <a name="user-content-regex"></a>Regex

Validate IP address

```sh
if [[ ! $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
  echo -e "error! $ip is not valid"
  return 1
fi
```

### <a name="user-content-function-in-function"></a>Function in Function

```sh
foo() (
  bar() {
    echo "hello"
  }

  bar
)
```

### <a name="user-content-modules"></a>Modules

inlude bash file as a module

```sh
.
├── foo.sh
└── modules
    └── utils.sh

$ cat modules/utils.sh
#!/bin/bash

function bar() {
  echo "hello"
}

$ cat foo.sh
#!/bin/bash

source modules/utils.sh

bar

```

## <a name="user-content-config-files"></a>Config Files

### <a name="user-content-yaml"></a>Yaml

Convert `yaml` file (work with up to level 2 of keys) to `key=value` environment variables file

- Detect if the input file's content changes with `md5()` hash
- allow bash to work with yaml for configuration automation

Requirements

- yq
- jq

Refer to [convert_yaml_to_env.sh](./scripts/convert_yaml_to_env.sh)

## <a name="user-content-cloud-provider"></a>Cloud Provider

### <a name="user-content-aws"></a>AWS

Getting VPC CIDR from VPC_ID

```sh
vpc_id=${1}
aws ec2 describe-vpcs --vpc-ids $vpc_id | jq -r .Vpcs[0].CidrBlock
```
