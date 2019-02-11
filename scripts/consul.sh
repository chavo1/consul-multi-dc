#!/usr/bin/env bash

SERVER_COUNT=${SERVER_COUNT}
CLIENT_COUNT=${CLIENT_COUNT}
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
    # check if consul file exist.
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
# check if we are on a server
  IS_SERVER=false

if [[ $HOST =~ server ]]; then
# if the name contain server we are there
  IS_SERVER=true

fi
# check DC
if [[ $IPs =~ 192.168.56 ]]; then # if 192.168.56 it is dc1

  dc=dc1
  LAN=',
    "retry_join": [
      "192.168.56.51",
      "192.168.56.52",
      "192.168.56.53"
    ]'
  if [ "$IS_SERVER" = true ] ; then # confirm if we are on dc1 server

    server=${SERVER_COUNT}
    WAN=',
      "retry_join_wan": [
        "192.168.57.51",
        "192.168.57.52",
        "192.168.57.53"
      ]'
  fi


elif [[ $IPs =~ 192.168.57 ]]; then  # if 192.168.57 it is dc2
  
  dc=dc2
  LAN=',
    "retry_join": [
      "192.168.57.51",
      "192.168.57.52",
      "192.168.57.53"
    ]'
    if [ "$IS_SERVER" = true ] ; then # confirm if we are on dc2 server
    
      server=${SERVER_COUNT}
      WAN=',
        "retry_join_wan": [
          "192.168.56.51",
          "192.168.56.52",
          "192.168.56.53"
        ]'
    fi

else 
  # In this case we not need else but after else must some command
  echo "Hello"
fi
# Creating consul configuration files - they are almost the same so - just a few variables
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
# starting consul agents
if [[ $HOST =~ server ]]; then
    # starting consul servers
    consul agent -server -ui -advertise $IPs -config-dir=/etc/consul.d > /vagrant/consul_logs/$HOST.log & 
else # starting consul clients
    consul agent -ui -advertise $IPs -config-dir=/etc/consul.d > /vagrant/consul_logs/$HOST.log & 

fi
set +x
sleep 5

consul members

