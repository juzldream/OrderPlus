#!/bin/bash
#
# By Young.zhang changed @20150115
# Add hosts to zabbix
#

if [[ ! -d "/etc/zagent" || ! -d "/etc/zabbix" ]]; then
    cd /tmp
    apt-get update --fix-missing
    apt-get update
    apt-get install zabbix-agent python-setuptools  python-dev libmysqld-dev python gcc mailutils -y
    wget --user='czar' --password='Czar.zabbix2014' http://zabbix.yeahmobi.com:8888/tivon/downloads/ops.yeahmobi.com.tar.gz;
    tar zxvf ops.yeahmobi.com.tar.gz;
    cd ops.yeahmobi.com/zabbix/zagent;
    python setup.py install
    rm -rf /tmp/ops.yeahmobi.com*
fi

ec2metadata=$(ec2metadata)
hostname=$(echo "${ec2metadata}" | grep "user-data" | awk -F"\"" '{print $4}' 2>&1)
rangeStr=$(echo -n ${hostname} | awk -F"-" '{print $2}')
if [[ "${rangeStr}#" == "#" ]]; then
    echo "Get Range Faild! Exit..."
    exit 1
fi

groupid=50
proxy_hostid=0
postdataurl=/tmp/zbxpostdata
zabbixapi="http://54.85.121.145:8888/api_jsonrpc.php"
IP=$(echo "${ec2metadata}" | grep "local-ipv4" | awk '{print $2}' 2>&1)

case "${rangeStr}" in
    "NCA" )
        server=10.3.255.21
        groupid=10
        proxy_hostid=10572
        ;;
    "IAD" )
        server=10.1.255.21
        groupid=12
        ;;
    "SIN" )
        server=10.2.255.21
        groupid=9
        proxy_hostid=10452
        ;;
    "SYD" )
        server=54.251.153.146
        groupid=13
        ;;
    "LON" )
        server=10.11.255.21
        groupid=14
        proxy_hostid=10579
        ;;
    "SP" )
        server=10.5.255.21
        groupid=41
        proxy_hostid=10574
        ;;
    "HK" )
        server=54.251.153.146
        groupid=15
        ;;
    * )
        echo "Not Support Range! Exit..."
        exit 1
        ;;
esac

cat > /etc/zabbix/zabbix_agentd.conf << EOF
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix-agent/zabbix_agentd.log
LogFileSize=0
Server=${server}
ServerActive=${server}
Hostname=${hostname}
Include=/etc/zabbix/zabbix_agentd.d/
UnsafeUserParameters=1
EOF


# if the host has existed
cat > ${postdataurl} << EOF
{
    "jsonrpc": "2.0", 
    "method": "host.get", 
    "auth": "afa736ff6d58c746efa28194b5e1af9f", 
    "id": 0,
    "params": {
        "output": "extend",
        "filter": {
            "host": [
                "${hostname}"
            ]
        }
    }   
}
EOF

curl -s -d "$(cat ${postdataurl} | sed 's/ //g')"  --header "Content-Type:application/json" "${zabbixapi}" | grep 'hostid'
result=$?

# add the host
if [[ "${result}" -eq "1" ]]; then

rm -rf ${postdataurl}
cat > ${postdataurl} << EOF
{
    "jsonrpc": "2.0", 
    "method": "host.create", 
    "auth": "afa736ff6d58c746efa28194b5e1af9f", 
    "id": 0,
    "params": {
        "templates": [
            {"templateid": "10198"}, 
            {"templateid": "10265"}, 
            {"templateid": "10319"}], 
        "host": "${hostname}", 
        "interfaces": [{
            "ip": "${IP}", 
            "useip": 1, 
            "dns": "", 
            "main": 1, 
            "type": 1, 
            "port": "10050"}],
        "groups": [{"groupid": "${groupid}"}],
        "proxy_hostid": "${proxy_hostid}"
    }   
}
EOF
curl -s -d "$(cat ${postdataurl} | sed 's/ //g')"  --header "Content-Type:application/json" "${zabbixapi}" >> /tmp/zabbix_add.log 2>&1
rm -rf ${postdataurl}
else
    echo "The host ${hostname} has exits!"   >> /tmp/zabbix_add.log 
fi

chmod -R 755 /etc/zabbix
/etc/init.d/zabbix-agent restart