#!/usr/bin/env bash

SERVER_COUNT_DC1=${SERVER_COUNT_DC1}
SERVER_COUNT_DC2=${SERVER_COUNT_DC2}
CLIENT_COUNT_DC1=${CLIENT_COUNT_DC1}
CLIENT_COUNT_DC2=${CLIENT_COUNT_DC2}
CONSUL_VERSION=${CONSUL_VERSION}
IPs=$(hostname -I | cut -f2 -d' ')
HOST=$(hostname)


# Install packages

which unzip socat jq dig route vim curl &>/dev/null || {
    apt-get update -y
    apt-get install unzip socat net-tools jq dnsutils vim curl -y 
}

#####################
# Installing consul #
#####################
sudo mkdir -p /vagrant/pkg

which consul || {
    # consul file exist.
    CHECKFILE="/vagrant/pkg/consul_${CONSUL_VERSION}_linux_amd64.zip"
    if [ ! -f "$CHECKFILE" ]; then
        pushd /vagrant/pkg
        wget https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip
        popd
 
    fi
    
    pushd /usr/local/bin/
    unzip /vagrant/pkg/consul_${CONSUL_VERSION}_linux_amd64.zip 
    sudo chmod +x consul
    popd
}

killall consul

sudo mkdir -p /etc/consul.d /vagrant/consul_logs
set -x
###########################
# Starting consul servers #
###########################

# for i in $(seq 21 29); do nc -v -n -z -w 1 192.168.0.$i 443; done


# y="10.10.10."

# for i in 10; do
#     if [ "$IPs" == "$y$i" ]; then
#         echo "all good"
#     else
#         echo "error"
#     fi
# done


for n in {1..3}; do
    echo $n
 
if [ $IPs == 192.168.56.5$n ]; then
LAN=',
  "retry_join": [
    "192.168.56.51",
    "192.168.56.52",
    "192.168.56.53"
  ]'
  WAN=''
  dc=dc1
  server=${SERVER_COUNT_DC1}

elif [[ $IPs == 192.168.57.5$n ]]; then
dc=dc2
LAN=',
  "retry_join": [
    "192.168.57.51",
    "192.168.57.52",
    "192.168.57.53"
  ]'
WAN=',
  "retry_join_wan": [
    "192.168.56.51",
    "192.168.56.52",
    "192.168.56.53"
  ]'
server=${SERVER_COUNT_DC2}

elif [[ $IPs == 192.168.56.6$n ]]; then
LAN=''
  dc=dc1
  client=${CLIENT_COUNT_DC1}
  LAN=',
  "retry_join": [
    "192.168.56.51",
    "192.168.56.52",
    "192.168.56.53"
  ]'

elif [[ $IPs == 192.168.57.6$n ]]; then
dc=dc2
LAN=',
  "retry_join": [
    "192.168.57.51",
    "192.168.57.52",
    "192.168.57.53"
  ]'
client=${CLIENT_COUNT_DC2}

fi

done

if [[ $HOST =~ server ]]; then
sudo cat <<EOF > /etc/consul.d/config.json
{
  "datacenter": "${dc}",
  "server": true,
  "ui": true,
  "client_addr": "0.0.0.0",
  "bind_addr": "0.0.0.0",
  "data_dir": "/usr/local/consul",
  "bootstrap_expect": ${server}${LAN}${WAN}
}
EOF

else

sudo cat <<EOF > /etc/consul.d/config.json
{
  "datacenter": "${dc}",
  "server": false,
  "ui": true,
  "client_addr": "0.0.0.0",
  "bind_addr": "0.0.0.0",
  "enable_script_checks": true,
  "data_dir": "/usr/local/consul"${LAN}
}
EOF
fi

if [[ $HOST =~ server ]]; then

    consul agent -server -ui -advertise $IPs -config-dir=/etc/consul.d > /vagrant/consul_logs/$HOST.log & 

else
    consul agent -ui -advertise $IPs -config-dir=/etc/consul.d > /vagrant/consul_logs/$HOST.log & 

fi
set +x
sleep 5

consul members

