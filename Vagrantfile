# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

###############################################################################
# Base box                                                                    #
###############################################################################
  config.vm.box = "puppetlabs/ubuntu-14.04-64-puppet"

###############################################################################
# Global provisioning settings                                                #
###############################################################################
  config.vm.provision "shell",inline: "sudo apt-get update"
  config.vm.synced_folder 'hiera/', '/var/lib/hiera'
  config.vm.provision :puppet do |puppet|
    default_env = 'development'
    ext_env = ENV['VAGRANT_PUPPET_ENV']
    env = ext_env ? ext_env : default_env
    puppet.options = "--environment #{env}"
    puppet.manifests_path = "puppet/environments/#{env}/manifests"
    puppet.manifest_file  = ""
    puppet.module_path = "puppet/modules"
    puppet.hiera_config_path = "puppet/hiera.yaml"
  end

###############################################################################
# Global VirtualBox settings                                                  #
###############################################################################
  config.vm.provider "virtualbox" do |v|
    v.customize [
      "modifyvm", :id,
      "--groups", "/Vagrant"
    ]
    v.memory = 4096
    v.cpus = 4
  end

###############################################################################
# VM definitions                                                              #
###############################################################################
  config.vm.define :playground do |playground|
    playground.vm.hostname = "playground.vagrant.local"
    playground.vm.network :private_network, ip: "192.168.42.42"
    playground.vm.provider("virtualbox") { |v| v.name = "playground" }
    playground.vm.synced_folder 'testbench', '/home/vagrant/testbench',
      owner: "vagrant", group: "vagrant"
  end
end
