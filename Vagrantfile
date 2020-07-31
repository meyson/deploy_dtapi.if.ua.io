# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.synced_folder ".", "/vagrant_data", disabled: true

  config.vm.provider "virtualbox" do |vb|
    vb.linked_clone = true
    vb.memory = "1024"
    vb.cpus = 2
  end

  # App Server 1
  config.vm.define "app" do |app|
    app.vm.hostname = "orc-app.test"
    app.vm.network :private_network, ip:ENV["SERVER_IP"]
    app.vm.synced_folder "./build/app", "/app", disabled: false
    app.vm.provision "shell", path: "vagrant_provision/app.sh"
  end

  # DB Server 1
  config.vm.define "db" do |db|
    db.vm.hostname = "orc-db.test"
    db.vm.network :private_network, ip:ENV["DB_IP"]
    db.vm.provision "shell",
        path: "vagrant_provision/db.sh",
        env: {
            "DATABASE" => ENV["DATABASE"],
            "DB_USER_NAME" => ENV["DB_USER_NAME"],
            "DB_USER_PWD" => ENV["DB_USER_PWD"],
            "DB_USER_HOST" => ENV["SERVER_IP"],
            "DB_IP" => ENV["DB_IP"]
        }
  end
end
