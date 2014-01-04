#
# Cookbook Name:: setting
# Recipe:: network
#
# Copyright 2014, Watabe Koki
#
# All rights reserved - Do Not Redistribute
#
template '/etc/sysconfig/network' do
  source 'etc/sysconfig/network.erb'
  owner 'root'
  group 'root'
  mode 0644
end

template '/etc/hosts' do
  source 'etc/hosts.erb'
  owner 'root'
  group 'root'
  mode 0644
end
