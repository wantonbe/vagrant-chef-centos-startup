#
# Cookbook Name:: setting
# Recipe:: selinux
#
# Copyright 2014, Watabe Koki
#
# All rights reserved - Do Not Redistribute
#
cookbook_file '/etc/selinux/config' do
  source 'etc/selinux/config'
  owner 'root'
  group 'root'
  mode 0644
end
