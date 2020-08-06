# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.synced_folder ".", "/vagrant_data", disabled: true

  config.vm.provider "virtualbox" do |vb|
    vb.linked_clone = true
    vb.memory = "700"
    vb.cpus = 2
  end

  # App Server 1
  config.vm.define "app1" do |app|
    app.vm.hostname = "orc-app1.test"
    app.vm.network :private_network, ip:ENV["SERVER_IP_1"]
    app.vm.synced_folder "./build/app", "/app", disabled: false
    app.vm.provision "shell", path: "vagrant_provision/app.sh"
  end

  # App Server 2
  config.vm.define "app2" do |app|
    app.vm.hostname = "orc-app2.test"
    app.vm.network :private_network, ip:ENV["SERVER_IP_2"]
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
            "SERVER_IP_1" => ENV["SERVER_IP_1"],
            "SERVER_IP_2" => ENV["SERVER_IP_2"],
            "DB_IP" => ENV["DB_IP"]
        }
  end

  # Load balancer
  config.vm.define "lb" do |be|
    be.vm.box = "centos/7"
    be.vm.hostname = "orc-lb.test"
    be.vm.network :private_network, ip: ENV["BE_LB_IP"]
    be.vm.provision "shell", path: "vagrant_provision/lb.sh",
    env: {
        "LB_IP" => ENV["LB_IP"],
        "SERVER_IP_1" => ENV["SERVER_IP_1"],
        "SERVER_IP_2" => ENV["SERVER_IP_2"],
    }
  end
end
