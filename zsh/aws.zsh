# Custom Functions
function asp() {
	if [[ -z "$1" ]]; then
		unset AWS_DEFAULT_PROFILE AWS_PROFILE AWS_EB_PROFILE
		echo AWS profile cleared.
		return
	fi
	local -a available_profiles
	available_profiles=($(aws_profiles))
	if [[ -z "${available_profiles[(r)$1]}" ]]; then
		echo "${fg[red]}Profile '$1' not found in '${AWS_CONFIG_FILE:-$HOME/.aws/config}'" >&2
		echo "Available profiles ${(j:, :)available_profiles:-no profiles found}${reset_color}" >&2
		return 1
	fi
    # aws-vault exec $1
	export AWS_DEFAULT_PROFILE=$1
	export AWS_PROFILE=$1
	export AWS_EB_PROFILE=$1
}

function aws_profiles() {
	[[ -r "${AWS_CONFIG_FILE:-$HOME/.aws/config}" ]] || return 1
	grep --color=never -Eo '\[.*\]' "${AWS_CONFIG_FILE:-$HOME/.aws/config}" | sed -E 's/^[[:space:]]*\[(profile)?[[:space:]]*([-_[:alnum:]\.@]+)\][[:space:]]*$/\2/g'
}

function _aws_profiles() {
	reply=($(aws_profiles))
}

# Auto Complete
compctl -K _aws_profiles asp

function ec2q {
    [[ -n "${1}" ]] || return 1;

    local output query remote user file
    local -a options optuser pairs

    output="table"
    pairs=(
        "Id:InstanceId"
        "IP:PrivateIpAddress"
        "State:State.Name"
        "AZ:Placement.AvailabilityZone"
        "Name:Tags[?Key==\`Name\`].Value|[0]"
        "DataDog:Tags[?Key==\`datadog\`].Value|[0]"
        "Type:InstanceType"
        "LaunchTime:LaunchTime"
        "AMI:ImageId"
        "Platform:Platform"
    )
    query="Reservations[*].Instances[*].{${(j:,:)pairs}}"

    # --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values=*${1}*" \
    # --filters "Name=tag:Name,Values=*${1}*" \
    filters="Name=tag:Name,Values=*${1}*"

    zparseopts -D -E -A options -- t id ip 1 s:: rmt:: f::

    for opt in "${(k@)options}"; do
        case "${opt}" in
            "-t" ) # filter by instance type
                filters="Name=instance-type,Values=${1}*"
                ;;
            "-id" ) # filter by instance id
                filters="Name=instance-id,Values=${1}"
                ;;
            "-1" ) # print the full JSON for the first result
                output="json"
                query="Reservations[0].Instances[0]"
                ;;
            "-ip" ) # only print IP addresses
                output="text"
                query="Reservations[*].Instances[*].[PrivateIpAddress]"
                ;;
            "-s" ) # state option
                filters+=""
                ;;
            "-rmt" ) # print user@ip for each host with the given user name
                remote=1
                user="${options[-rmt]}"
                [[ -n "${user}" ]] || { echo "-u must be defined with -rmt" && return 1 }
                output="text"
                query="Reservations[*].Instances[*].[PrivateIpAddress]"
                ;;
        esac
    done

    # cmd="aws ec2 describe-instances --filters \"${filters}\" --query \"${query}\" --output \"${output}\""
    # echo "[${cmd}]"
    res=$(aws ec2 describe-instances --filters "${filters}" --query "${query}" --output "${output}")

    if [ "${remote}" = "1" ]; then
        for ip in ${(f)res}; do
            echo "${user}@${ip}"
        done
        return 0
    fi

    echo "${res}"
}