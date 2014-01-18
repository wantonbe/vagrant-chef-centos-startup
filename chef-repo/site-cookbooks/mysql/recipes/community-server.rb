#
# Cookbook Name:: mysql
# Recipe:: community-server
#
# Copyright 2014, Watabe Koki
#
# All rights reserved - Do Not Redistribute

if node['mysql']['server'].has_key?('data_bag_name') && node['mysql']['server'].has_key?('data_bag_item_name')
  bag_name = node['mysql']['server']['data_bag_name']
  bag_item_name = node['mysql']['server']['data_bag_item_name']
  
  if Chef::Config[:encrypted_data_bag_secret]
    bag_item = Chef::EncryptedDataBagItem.load("#{bag_name}", "#{bag_item_name}").to_hash
  end
  
  bag_item ||= data_bag_item("#{bag_name}", "#{bag_item_name}")
  
  %w{server_debian_password server_root_password server_repl_password}.each do |key|
    node.default['mysql'][key] = bag_item[key]
  end
end

include_recipe 'yum::mysql-community'

%w{mysql-community-server}.each do |srv|
  package "#{srv}" do
    action :install
  end
end

service 'mysqld' do
  supports :start => true, :stop => true, :restart => true, :reload => true
  action :nothing
end

template '/etc/my.cnf' do
  source 'my.cnf.erb'
  owner  'root'
  group  'root'
  notifies :restart, "service[mysqld]", :immediately
end

execute 'assign_root_password' do
  command "/usr/bin/mysqladmin -u root password #{node['mysql']['server_root_password']}"
  action :run
  only_if "/usr/bin/mysql -u root -e 'show databases;'"
end

template '/etc/mysql_grants.sql' do
  source 'grants.sql.erb'
  owner  'root'
  group  'root'
  mode   '0600'
  action :create
  notifies :run, "execute[install-grants]", :immediately
end

execute 'install-grants' do
  command "/usr/bin/mysql -u root -p#{node['mysql']['server_root_password']} < /etc/mysql_grants.sql"
  action :nothing
  notifies :restart, 'service[mysqld]', :immediately
end

