# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.synced_folder ".", "/vagrant_data", disabled: true

  config.vm.provider "virtualbox" do |vb|
    vb.linked_clone = true
    vb.memory = "512"
  end

  # App Server 1
  config.vm.define "app" do |app|
    app.vm.hostname = "orc-app.test"
    app.vm.network :private_network, ip:"192.168.60.4"
    config.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
        vb.cpus = 4
    end
    app.vm.synced_folder "./front-end_build", "/front-end_build", disabled: false
    app.vm.provision "shell", path: "app_provision.sh" 
  end

  # DB Server 1
  config.vm.define "db" do |db|
    db.vm.hostname = "orc-db.test"
    db.vm.network :private_network, ip:"192.168.60.5"
    db.vm.provision "shell", path: "db_provision.sh" 
  end
end