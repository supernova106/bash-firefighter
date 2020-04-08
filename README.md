# bash-firefighter

Curated list of useful bash techniques

## Table of Contents

- [Helper](#helper)
- [Generic](#generic)
- [Programming](#programming)
- [Config Files](#config-files)
- [Cloud Provider](#cloud-provider)

## <a name="helper"></a>Helper

- yq, refer to [install_yq.sh](./scripts/install_yq.sh)
- jq, refer to [install_jq.sh](./scripts/install_jq.sh)

## <a name="generic"></a>Generic

- Get local directory of script [local_dir.sh](./scripts/local_dir.sh)
- Get OS platform [get_os.sh](./scripts/get_os.sh)

## <a name="programming"></a>Programming

### <a name="array"></a>Array

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

### <a name="regex"></a>Regex

Validate IP address

```sh
if [[ ! $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
  echo -e "error! $ip is not valid"
  return 1
fi
```

## <a name="config-files"></a>Config Files

### <a name="yaml"></a>Yaml

Convert `yaml` file (work with up to level 2 of keys) to `key=value` environment variables file

- Detect if the input file's content changes with `md5()` hash
- allow bash to work with yaml for configuration automation

Requirements

- yq
- jq

Refer to [convert_yaml_to_env.sh](./scripts/convert_yaml_to_env.sh)

## <a name="cloud-provider"></a>Cloud Provider

### <a name="aws"></a>AWS

Getting VPC CIDR from VPC_ID

```sh
$vpc_id=${1}
aws ec2 describe-vpcs --vpc-ids $vpc_id | jq -r .Vpcs[0].CidrBlock
```
