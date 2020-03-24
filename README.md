# bash-firefighter
Curated list of useful bash techniques

## Table of Contents
* [Helper](#user-content-helper)
* [Generic](#user-content-generic)
  * [Check bash version](#user-content-check-bash-version)
  * [Check command exists](#user-content-check-command-exist)
  * [Check OS](#user-content-check-os)
  * [Debug Mode](#user-content-debug-mode)
  * [Exit on error](#user-content-exit-on-error)
  * [Retry on error](#user-content-retry-on-error)
  * [User continue](#user-content-user-continue)
* [Programming](#user-content-programming)
  * [Array](#user-content-array)
  * [Join](#user-content-join-method)
  * [Variables](#user-content-variables)
  * [Split](#user-content-split-method)
  * [Regex](#user-content-regex)
  * [Modules](#user-content-modules)
  * [Function in Function](#user-content-function-in-function)
* [Config Files](#user-content-config-files)
  * [Convert YAML to key=value](#user-content-yaml)
* [Cloud Provider](#user-content-cloud-provider)
  * [AWS](#user-content-aws)

## <a name="user-content-helper"></a>Helper

* yq

```sh
pip install python-yq==2.10.0
```

* jq

```sh
jq_version="1.6"
cd /tmp/ && wget -q "https://github.com/stedolan/jq/releases/download/jq-${jq_version}/jq-linux64" && \
        sudo cp jq-linux64 /usr/local/bin/jq && \
        sudo chmod +x /usr/local/bin/jq
```

## <a name="user-content-generic"></a>Generic

### <a name="user-content-check-bash-version"></a>Check Bash Version

```sh
bash --version
```

### <a name="user-content-check-command-exist"></a>Check Command Exist

```sh
command -v ${command_name} >/dev/null 2>&1 || echo "${command_name} not found!"
```

### <a name="user-content-debug-mode"></a>Debug mode

```sh
#!/bin/bash
set -x
```

### <a name="user-content-exit-on-error"></a>Exit on error

```sh
#!/bin/bash
set -e
```

### <a name="user-content-check-os"></a>Check OS

```sh
get_os() {
    unameOut="$(uname -s)"
    local machine=""
    case "${unameOut}" in
        Linux*)     machine=Linux;;
        Darwin*)    machine=Mac;;
        CYGWIN*)    machine=Cygwin;;
        MINGW*)     machine=MinGw;;
        *)          machine="UNKNOWN:${unameOut}"
    esac

    echo "$machine"
}
```

### <a name="user-content-retry-on-error"></a>Retry on error

```sh
function retry {
  local retries="${1}"
  shift

  local count=0
  until "$@"; do
    exit=$?
    wait=$((2 ** $count))
    count=$(($count + 1))
    if [ $count -lt $retries ]; then
      echo "Retry $count/$retries exited $exit, retrying in $wait seconds..."
      sleep $wait
    else
      echo "Retry $count/$retries exited $exit, no more retries left."
      return $exit
    fi
  done
  return 0
}

# retry 2 echo "hello"
# retry 3 false
```

### <a name="user-content-user-continue"></a>User Continue

```sh
function user_continue() {
    while true; do
      read -r -p "Continue? [Y/N]" yn
      case $yn in
          [Yy]* ) break;;
          [Nn]* ) echo "aborting";exit;;
          * ) echo "Please answer y for yes or n for no.";;
      esac
    done
}

user_continue
```

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

- python-yq >= 2.10.0
- jq


```sh
convert_yaml_to_env() {
    local arr=""
    local value=""
    local master_keys_arr=""
    local yaml_config_file=""
    local yaml_config_data=""
    local current_hash=""
    local new_hash=""
    local output_file_path=""

    output_file_path="${PWD}"
    yaml_config_file="${1}"

    if [ "${yaml_config_file}" == "" ]; then
        echo "yaml_config_file is required. function source_cluster_config_yaml_to_env() failed" 
	return 1
    fi 
    yaml_config_data=$(cat "$yaml_config_file")

    new_hash=$(md5sum "$yaml_config_file" | awk '{ print $1 }')
    if [ -f "${output_file_path}/config.env" ]; then
        current_hash=$(head -n 1 "${output_file_path}/config.env" | grep 'hash_id' | awk -F'=' '{ print $2 }')
    fi
    
    echo -e "Generating config.env from config.yaml..."

    if [ "${new_hash}" != "${current_hash}" ]; then
        echo "# hash_id=${new_hash}" > "${output_file_path}"/config.env  
    else
        echo -e "hashid=${current_hash}. No change is found on config.yaml"
        return 0
    fi

    master_keys_arr=()
    while IFS='' read -r line; do
    master_keys_arr+=("$line")
    done < <(echo -e "${yaml_config_data}" | yq '.'  - | jq -r 'keys[]')
    
    for master_key in "${master_keys_arr[@]}"
    do
	    arr=()
	    while IFS='' read -r line; do
	    	arr+=("$line")
	    done < <(echo -e "${yaml_config_data}" | yq .${master_key}  - | jq -r 'keys[]')

	    for key in "${arr[@]}"
	    do
		value=$(echo -e "${yaml_config_data}" | yq -r .${master_key}.${key} -)
		echo -e  "$key=\$(cat <<EOF\n${value}\nEOF\n)" >> "${output_file_path}"/config.env
	    done
    done

    echo -e "generated ${output_file_path}/config.env"
    return 0
}

convert_yaml_to_env config.yaml

```

## <a name="user-content-cloud-provider"></a>Cloud Provider

### <a name="user-content-aws"></a>AWS

Getting VPC CIDR from VPC_ID

```sh
vpc_id=${1}
aws ec2 describe-vpcs --vpc-ids $vpc_id | jq -r .Vpcs[0].CidrBlock
```
