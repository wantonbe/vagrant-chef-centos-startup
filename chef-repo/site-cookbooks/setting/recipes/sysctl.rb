#
# Cookbook Name:: setting
# Recipe:: sysctl
#
# Copyright 2014, Watabe Koki
#
# All rights reserved - Do Not Redistribute
#
cookbook_file '/etc/sysctl.conf' do
  source 'etc/sysctl.conf'
  owner 'root'
  group 'root'
  mode 0644
end
