# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
  config.vm.box = "ssplatt/rocky9"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "4096"
    vb.cpus = "2"
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
    config.vm.provision "shell", path: "provision.sh"
  end
  config.vm.provider "vmware_desktop" do |vp|
    vp.memory = "4096"
    vp.cpus = "2"
    config.vm.provision "shell", path: "provision.sh"
  end
  config.vm.provider "digital_ocean" do |provider|
    provider.token = ENV['DO_API_TOKEN'] || ""
    provider.image = "ubuntu-22-04-x64"
    provider.region = "nyc1"
    provider.size = "s-2vcpu-4gb"
    provider.ssh_key_name = "vagrant"
    provider.ssh_key_path = ENV['DO_SSH_KEY_PATH'] || "~/.ssh/id_rsa"
    config.vm.provision "shell", path: "do_runner.sh"
  end
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end
end
  