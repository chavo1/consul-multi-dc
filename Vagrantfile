SERVER_COUNT = 1
CLIENT_COUNT = 1
CONSUL_VERSION = '1.4.2'
CONSUL_TEMPLATE_VERSION = '0.19.5'
WAN = true

Vagrant.configure(2) do |config|
    config.vm.box = "chavo1/xenial64base"
    config.vm.provider "virtualbox" do |v|
      v.memory = 512
      v.cpus = 2
    
    end
    # 'a' count the DCs 'b' count the IPs (increase with 1)
    ["dc1", "dc2"].to_enum.with_index(1).each do |a, b|

    1.upto(SERVER_COUNT) do |n|
      config.vm.define "consul-#{a}-server0#{n}" do |server|
        server.vm.hostname = "consul-#{a}-server0#{n}"
        server.vm.network "private_network", ip: "192.168.#{55+b}.#{50+n}"
        server.vm.provision "shell",inline: "cd /vagrant ; bash scripts/consul.sh", env: {"WAN" => WAN, "CONSUL_VERSION" => CONSUL_VERSION, "SERVER_COUNT" => SERVER_COUNT}

      end
    end

    1.upto(CLIENT_COUNT) do |n|
      config.vm.define "consul-#{a}-client0#{n}" do |client|
        client.vm.hostname = "consul-#{a}-client0#{n}"
        client.vm.network "private_network", ip: "192.168.#{55+b}.#{60+n}"
        client.vm.provision "shell",inline: "cd /vagrant ; bash scripts/consul.sh", env: {"WAN" => WAN, "CONSUL_VERSION" => CONSUL_VERSION, "CLIENT_COUNT" => CLIENT_COUNT}
        client.vm.provision "shell",inline: "cd /vagrant ; bash scripts/consul-template.sh", env: {"CONSUL_TEMPLATE_VERSION" => CONSUL_TEMPLATE_VERSION}
        client.vm.provision "shell",inline: "cd /vagrant ; bash scripts/kv.sh"
        client.vm.provision "shell",inline: "cd /vagrant ; bash scripts/nginx.sh"
        client.vm.provision "shell",inline: "cd /vagrant ; bash scripts/dns.sh"
      
      end
    end
  end
end
