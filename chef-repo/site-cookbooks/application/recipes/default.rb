#
# Cookbook Name:: application
# Recipe:: default
#
# Copyright 2014, Watabe Koki
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'application::php'
include_recipe 'application::nginx'

node.run_state['document_root'] = '/srv/application/public'

directory "#{node.run_state['document_root']}" do
  owner "#{node[:php][:fpm_user]}"
  group "#{node[:php][:fpm_group]}"
  recursive true
  action :create
end

%w{hello.html phpinfo.php}.each do |name|
  cookbook_file "#{name}" do
    path "#{node.run_state['document_root']}/#{name}"
    source "public/#{name}"
    owner "#{node[:php][:fpm_user]}"
    group "#{node[:php][:fpm_group]}"
    mode 0644
  end
end

node.run_state.delete('document_root')

include_recipe 'application::composer'
