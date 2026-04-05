###THIS VAGRANT FILE IS FOR THE CUSTOMIZED VIRTUAL MACHINE WHICH USED FOR THE WORDPRESS SETUPS"""

Vagrant.configure("2") do |config|
    #vagrant box configuration
    config.vm.box = "ubuntu/jammy64"
    #vagrant private network configuration
    config.vm.network "private_network", ip: "192.168.56.76"
#vagrant public network configuration
   config.vm.network "public_network", bridge: "en0: Wi-Fi (AirPort)"
    #vagrant provider configuration
    config.vm.provider "virtualbox" do |vb|
        vb.memory = "2048"
        vb.cpus = 2
    end

#vagrant provisioning configuration
config.vm.provision "shell", path: "provisioning/wprdpress.sh"

#vagrant vm boot timeout configuration
config.vm.boot_timeout = 1200
end
