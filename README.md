# bash-firefighter
Curated list of useful bash techniques

## Table of Contents
* [Helper](#user-content-helper)
* [Generic](#user-content-generic)
* [Programming](#user-content-programming)
  * [Array](#user-content-array)
  * [Regex](#user-content-regex)
* [Config Files](#user-content-config-files)
  * [Yaml](#user-content-yaml)
* [Cloud Provider](#user-content-cloud-provider)
  * [AWS](#user-content-aws)

## <a name="user-content-helper"></a>Helper

* brew

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

* yq
* jq

```sh
brew install python-yq

```

## <a name="user-content-generic"></a>Generic

Debug mode

```sh
#!/bin/bash
set -x
```

Exit on error

```sh
#!/bin/bash
set -e
```

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

source utils.sh

bar

```

Get OS platform

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

### <a name="user-content-regex"></a>Regex

Validate IP address

```sh
if [[ ! $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
  echo -e "error! $ip is not valid"
  return 1
fi
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
$vpc_id=${1}
aws ec2 describe-vpcs --vpc-ids $vpc_id | jq -r .Vpcs[0].CidrBlock
```
