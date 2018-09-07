#!/bin/bash
# This script is used to list all IP addresses belongs to given Pod/Gateway in Apigee 
# example 1: ./apigee_list_ip.sh http://apigee-mgmt-server-ip:8080 user@mail.com pasword@123
# Apigee pods ar three types: gateway, central and analytics, if option is empty then will generate all pods IPs
_list_ip()
{       
	ipList=""
	result=""
        echo -e "\nIP List from Apigee $cluster Pod:$pod..... $apigeeurl"
		if [[ "$pod" == "gateway" ]]; then	
			result=$(curl -s -u ${username}:${password} $URL | /usr/local/sbin/jq '.[] | { internalIP:.internalIP,type:.type[0] } | select ( .type == "router") | del (.type)' )
		else
			result=$(curl -s -u ${username}:${password} $URL | /usr/local/sbin/jq '.[] | { "internalIP"}' )
		fi
		#echo  $result
		if [[ "$result" != "" ]]; then
			result=$result |xargs
			result=${result//\"/}
	        result=${result//internalIP/}
			result=${result//\{/}
			result=${result//\}/}
			result=${result//:/}
			result=${result//,/}
			result=${result// /}
		
			result=$result |xargs

			result=$(echo  $result)
			#	IFS=",[]{}' :"
			for ip in $result
			do
				ip=${ip//\"/}
				if [[ "$ip" != "" ]] && [[ "$ip" != " " ]] && [[ "$ip" != "$temp" ]]; then
				if expr "$ip" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null; then
					echo $ip
					ipList="$ipList,$ip"
					temp=$ip
				fi
				fi
			done
		fi
#echo $ipList
}
  
_list_ip_main()
{
apigeeurl=$1
username=$2
password=$3
pod=$4
cluster=$5
ipList=""
URL=""

if [[ "$apigeeurl" == "" ]] || [[ "$username" == "" ]] || [[ "$password" == "" ]]; then
	echo " usage: ./apigee_list_ip.sh <apigee mgmt server url> <username> <password> [<pod-name optional>]"
	echo " example 1: ./apigee_list_ip.sh http://api-dev.apigee.cloud:8080 user@apigee.com A1ndi@123"
	exit
fi

if [[ "$1" == "" ]]; then
	apigeeurl="http://localhost:8080"
fi
if [[ "$2" == "" ]]; then
	username="admin@aeg.cloud"
fi
if [[ "$3" == "" ]]; then
	password="password#123"
fi
if [[ "$pod" == "" ]]; then
pod="analytics"
URL=${apigeeurl}/v1/servers?pod=analytics
_list_ip
pod="central"
URL=${apigeeurl}/v1/servers?pod=central
_list_ip
pod="gateway"
URL=${apigeeurl}/v1/servers?pod=gateway
_list_ip
fi
if [[ "$pod" == "gateway" ]]; then
URL=${apigeeurl}/v1/servers?pod=gateway
_list_ip
fi
if [[ "$pod" == "analytics" ]]; then
URL=${apigeeurl}/v1/servers?pod=analytics
_list_ip
fi
if [[ "$pod" == "central" ]]; then
URL=${apigeeurl}/v1/servers?pod=central
_list_ip
fi
echo "Please see IP list in the file  /tmp/apigee_ip_list.log"
}

#  Health Check Main  
# usage: ./apigee_list_ip.sh <apigee mgmt server url> <username> <password> [<pod-name optional>]

clear
#_list_ip_main "$1" "$2" "$3" "$4" |&  tee ./apigee_ip_list.log

_list_ip_main "http://10.0.0.1:8080" "admin@apigee.com" "admin@123" "gateway" "Cluster A" |& tee  ./apigee_ip_list.log


