## This repo contains a sample of Consul cluster in multi-datacenter deployment. 
#### It will spin up 8 Vagrant machines with 3 Consul servers - 1 Consul client in dc1 and 3 Consul servers - 1 Consul client in dc2.

#### The usage is pretty simple

- Vagrant should be [installed](https://www.vagrantup.com/)
- Git should be [installed](https://git-scm.com/)
- Since [Consul](https://www.consul.io/) require at least 3 servers in order to survive 1 server failure. Quorum requires at least (n/2)+1 members. If we need more servers, clients or a specific Consul version - it is simple as just change the numbers in the Vagrantfile
```
SERVER_COUNT = 3
CLIENT_COUNT = 1
CONSUL_VERSION = '1.4.0'
CONSUL_TEMPLATE_VERSION = '0.19.5'
```
#### I have changed the [NGINX](https://www.nginx.com/resources/wiki/) Welcome page with [consul-template](https://github.com/hashicorp/consul-template)

### Now we are ready to start, just follow the steps:

- Clone the repo
```
git clone git@github.com:chavo1/consul-multi-dc.git
cd consul-multi-dc
```
- Start the lab
```
vagrant up
```
#### Check if Consul UI is available on the following addresses:
##### DC1
- Servers: http://192.168.56.51:8500 etc.
- Clients: http://192.168.56.61:8500 etc.
- NGINX: http://192.168.56.61 etc.
##### DC2
- Servers: http://192.168.57.51:8500 etc.
- Clients: http://192.168.57.61:8500 etc.
- NGINX: http://192.168.57.61 etc.
#### Test with infinite_loop.sh
```
vagrant ssh consul-dc2-client01
sudo su -
/vagrant/scripts/infinite_loop.sh # must be stopped manually
```
#### open another console
```
vagrant ssh consul-dc2-client01
sudo su -
curl \
    --request POST \
    --data \
'{
  "Name": "web",
  "Service": {
    "Service": "web",
    "Failover": {
      "NearestN": 2,
      "Datacenters": ["dc1", "dc2"]
    }
  }
}' http://127.0.0.1:8500/v1/query
systemctl stop nginx
```
#### The last command will stop nginx service and Failover will occur (traffic will be redirected to the  dc1). In query.txt you can find more queries. To switch again to dc1 just start nginx.
```
systemctl start nginx
tail -f /vagrant/conul_log/loop.log
```
#### In loop.log you will be able to see redirection in real time

#### Create and restore the snapshot manually
- From Vagrantfile change the WAN to false - this will create two independent DCs
```
vagrant ssh consul-dc1-server01
mkdir -p /vagrant/snapshot
consul snapshot save /vagrant/snapshot/backup.snap
```
- Login to the server in second DC
```
vagrant ssh consul-dc2-server01
consul snapshot inspect /vagrant/snapshot/backup.snap # this will show the info about snapshot
consul snapshot restore /vagrant/snapshot/backup.snap # this will restore the snapshot on the second server
```
- Open the KV Store of consul-dc2-server01 and check for the restored data
- More information could be found [HERE](https://www.consul.io/docs/commands/snapshot.htmlwihch consul)
