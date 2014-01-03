# -*- mode: ruby -*-

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define "dev-web" do |web|
    web.vm.box = "CentOS-6.4-x86_64"
  
    web.vm.box_url = "http://developer.nrel.gov/downloads/vagrant-boxes/CentOS-6.4-x86_64-v20130427.box"
  
    # web.vm.network :forwarded_port, guest: 80, host: 8080
  
    web.vm.network :private_network, ip: "172.16.1.100"
  
    # Share an additional folder to the guest VM. The first argument is
    # the path on the host to the actual folder. The second argument is
    # the path on the guest to mount the folder. And the optional third
    # argument is a set of non-required options.
    # web.vm.synced_folder "../data", "/vagrant_data"
  
    web.vm.provider :virtualbox do |vb|
      # # Don't boot with headless mode
      # vb.gui = true
    
      # Use VBoxManage to customize the VM. For example to change memory:
      vb.name = "dev-web"
      vb.customize ["modifyvm", :id , "--cpus", "1"]
      vb.customize ["modifyvm", :id , "--memory", "1024"]
      vb.customize ["modifyvm", :id , "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id , "--natdnsproxy1", "on"]
    end
  
    # Enable provisioning with chef solo, specifying a cookbooks path, roles
    # path, and data_bags path (all relative to this Vagrantfile), and adding
    # some recipes and/or roles.
    #
    # web.vm.provision :chef_solo do |chef|
    #   chef.cookbooks_path = ["./chef-repo/cookbooks", "./chef-repo/site-cookbooks"]
    #   chef.roles_path = "./chef-repo/roles"
    #   chef.data_bags_path = "./chef-repo/data_bags"
    #   chef.add_role "web"
    #
    #   # You may also specify custom JSON attributes:
    #   chef.json = { :mysql_password => "foo" }
    # end
  end
end
