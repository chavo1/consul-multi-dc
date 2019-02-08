SERVER_COUNT_DC1 = 3
SERVER_COUNT_DC2 = 3
CLIENT_COUNT_DC1 = 1
CLIENT_COUNT_DC2 = 1
CONSUL_VERSION = '1.4.2'
CONSUL_TEMPLATE_VERSION = '0.19.5'

Vagrant.configure(2) do |config|
    config.vm.box = "chavo1/xenial64base"
    config.vm.provider "virtualbox" do |v|
      v.memory = 512
      v.cpus = 2
    
    end

    1.upto(SERVER_COUNT_DC1) do |n|
      config.vm.define "consul-dc1-server0#{n}" do |server|
        server.vm.hostname = "consul-dc1-server0#{n}"
        server.vm.network "private_network", ip: "192.168.56.#{50+n}"
        server.vm.provision "shell",inline: "cd /vagrant ; bash scripts/consul.sh", env: {"CONSUL_VERSION" => CONSUL_VERSION, "SERVER_COUNT_DC1" => SERVER_COUNT_DC1}

      end
    end

    1.upto(CLIENT_COUNT_DC1) do |n|
      config.vm.define "consul-dc1-client0#{n}" do |client|
        client.vm.hostname = "consul-dc1-client0#{n}"
        client.vm.network "private_network", ip: "192.168.56.#{60+n}"
        client.vm.provision "shell",inline: "cd /vagrant ; bash scripts/consul.sh", env: {"CONSUL_VERSION" => CONSUL_VERSION, "CLIENT_COUNT_DC1" => CLIENT_COUNT_DC1}
        client.vm.provision "shell",inline: "cd /vagrant ; bash scripts/consul-template.sh", env: {"CONSUL_TEMPLATE_VERSION" => CONSUL_TEMPLATE_VERSION}
        client.vm.provision "shell",inline: "cd /vagrant ; bash scripts/kv.sh"
        client.vm.provision "shell",inline: "cd /vagrant ; bash scripts/nginx.sh"
        
      end
    end

    1.upto(SERVER_COUNT_DC2) do |n|
      config.vm.define "consul-dc2-server0#{n}" do |server|
        server.vm.hostname = "consul-dc2-server0#{n}"
        server.vm.network "private_network", ip: "192.168.57.#{50+n}"
        server.vm.provision "shell",inline: "cd /vagrant ; bash scripts/consul.sh", env: {"CONSUL_VERSION" => CONSUL_VERSION, "SERVER_COUNT_DC2" => SERVER_COUNT_DC2}

      end
    end

    1.upto(CLIENT_COUNT_DC2) do |n|
      config.vm.define "consul-dc2-client0#{n}" do |client|
        client.vm.hostname = "consul-dc2-client0#{n}"
        client.vm.network "private_network", ip: "192.168.57.#{60+n}"
        client.vm.provision "shell",inline: "cd /vagrant ; bash scripts/consul.sh", env: {"CONSUL_VERSION" => CONSUL_VERSION, "CLIENT_COUNT_DC2" => CLIENT_COUNT_DC2}
        client.vm.provision "shell",inline: "cd /vagrant ; bash scripts/consul-template.sh", env: {"CONSUL_TEMPLATE_VERSION" => CONSUL_TEMPLATE_VERSION}
        client.vm.provision "shell",inline: "cd /vagrant ; bash scripts/kv.sh"
        client.vm.provision "shell",inline: "cd /vagrant ; bash scripts/nginx.sh"
        
      end
    end
  end
