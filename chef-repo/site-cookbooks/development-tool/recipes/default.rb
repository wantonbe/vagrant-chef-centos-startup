#
# Cookbook Name:: development-tool
# Recipe:: default
#
# Copyright 2014, Watabe Koki
#
# All rights reserved - Do Not Redistribute
#

include_recipe "development-tool::git"
include_recipe "development-tool::vim"

%w{develop}.each do |group|

  data_bag("users").each do |bag_item_name|
    if Chef::Config[:encrypted_data_bag_secret]
      bag_item = Chef::EncryptedDataBagItem.load("users", "#{bag_item_name}").to_hash
    end
    
    bag_item ||= data_bag_item("#{bag_name}", "#{bag_item_name}")
    groups = bag_item['groups'].is_a?(Array) ? bag_item['groups'] : [ bag_item['groups'] ]
    if groups.include?("#{group}")
      u = bag_item
      u['username'] ||= u['id']
  
      if u['home']
        home_dir = u['home']
      else
        home_dir = "/home/#{u['username']}"
      end
  
      if home_dir != "/dev/null"
        template "#{home_dir}/.bashrc" do
          source 'bashrc.erb'
          owner u['username']
          group u['gid'] || u['username']
          mode "0644"
        end
  
        template "#{home_dir}/.bash_profile" do
          source 'bash_profile.erb'
          owner u['username']
          group u['gid'] || u['username']
          mode "0644"
        end
  
        template "#{home_dir}/.vimrc" do
          source "vimrc.erb"
          owner u['username']
          group u['gid'] || u['username']
          mode "0644"
        end
      end
    end
  end
end
