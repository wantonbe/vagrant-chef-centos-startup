#
# Cookbook Name:: application
# Recipe:: nginx
#
# Copyright 2014, Watabe Koki
#
# All rights reserved - Do Not Redistribute
#
include_recipe "nginx"

cookbook_file 'php-fpm' do
  path "#{node['nginx']['dir']}/conf.d/php-fpm"
  source 'nginx/conf.d/php-fpm'
  owner "root"
  group "root"
  mode 0644
end

# deploy your sites configuration from the files/ directory in your cookbook
template 'dev.local' do
  path "#{node['nginx']['dir']}/sites-available/dev.local"
  source 'nginx/sites-available.erb'
  owner "root"
  group "root"
  mode 0644
end

# enable your sites configuration using a definition from the nginx cookbook
nginx_site 'dev.local' do
  action :enable
end
