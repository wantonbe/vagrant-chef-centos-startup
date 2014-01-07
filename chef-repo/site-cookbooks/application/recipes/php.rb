#
# Cookbook Name:: application
# Recipe:: php
#
# Copyright 2014, Watabe Koki
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'php'

# deploy your sites configuration from the files/ directory in your cookbook
template 'php.ini' do
  path "#{node['php']['conf_dir']}/php.ini"
  source 'php/php.ini.erb'
  owner "root"
  group "root"
  mode 0644
  variables(:directives => node['php']['directives'])
end

template 'php-fpm.init' do
  path '/etc/init.d/php-fpm'
  source 'php/php-fpm.init.erb'
  owner "root"
  group "root"
  mode 0755
end

template 'php-fpm.conf' do
  path node['php-fpm']['conf_file']
  source 'php/php-fpm.conf.erb'
  owner "root"
  group "root"
  mode 0644
  notifies :restart, "service[php-fpm]"
end

%w{pool_conf_dir log_dir pid_dir}.each do |name|
  directory "#{node['php-fpm'][name]}" do
    owner "root"
    group "root"
    action :create
  end
end

service 'php-fpm' do
  supports :start => true, :stop => true, :restart => true, :reload => true
  action [:enable, :start]
end
