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
  owner 'vagrant'
  group 'vagrant'
  recursive true
  action :create
end

%w{hello.html phpinfo.php}.each do |name|
  cookbook_file "#{name}" do
    path "#{node.run_state['document_root']}/#{name}"
    source "public/#{name}"
    owner "vagrant"
    group "vagrant"
    mode 0644
  end
end

node.run_state.delete('document_root')
