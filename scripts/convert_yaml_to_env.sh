#!/bin/bash

YQ_BIN=$(which yq)
JQ_BIN=$(which jq)

cat <<EOT >> config.yaml
---
hello: world
foo:
  bar: test
EOT

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
    env_config_file="${output_file_path}/config.env"

    if [ ! -f "${yaml_config_file}" ]; then
        print_error "${yaml_config_file} not found."
    fi

    # validate yaml
    $YQ_BIN v "${yaml_config_file}"

    # remove faulty config.env
    if [ -f ${env_config_file} ] && [ "$(cat ${env_config_file} | wc -l)" -lt 3 ]; then
        rm ${env_config_file}
    fi

    if [ "${yaml_config_file}" == "" ]; then
        print_error "yaml_config_file is required. function source_cluster_config_yaml_to_env() failed" 
    fi 
    yaml_config_data=$(cat "$yaml_config_file")

    new_hash=$(md5sum "$yaml_config_file" | awk '{ print $1 }')
    if [ -f "${env_config_file}" ]; then
        current_hash=$(head -n 1 "${env_config_file}" | grep 'hash_id' | awk -F'=' '{ print $2 }')
    fi
    
    echo -e "Generating config.env from config.yaml..."

    if [ "${new_hash}" != "${current_hash}" ]; then
        echo "# hash_id=${new_hash}" > "${env_config_file}"  
    else
        echo -e "hashid=${YELLOW}${current_hash}${RESET}. No change is found on config.yaml"
        return 0
    fi

    master_keys_arr=()
    while IFS='' read -r line; do
    master_keys_arr+=("$line")
    done < <(echo -e "${yaml_config_data}" | $YQ_BIN r -j - | $JQ_BIN -r 'keys[]')
    
    for master_key in "${master_keys_arr[@]}"
    do
	    arr=()
	    while IFS='' read -r line; do
	    	arr+=("$line")
	    done < <(echo -e "${yaml_config_data}" | $YQ_BIN r -j - ${master_key} | $JQ_BIN -r 'keys[]')

	    for key in "${arr[@]}"
	    do
		value=$(echo -e "${yaml_config_data}" | $YQ_BIN r -j - ${master_key}.${key})
		echo -e  "$key=\$(cat <<EOF\n${value}\nEOF\n)" >> "${env_config_file}"
	    done
    done

    echo -e "generated ${GREEN}${env_config_file}${RESET}"
    return 0
}

convert_yaml_to_env config.yaml