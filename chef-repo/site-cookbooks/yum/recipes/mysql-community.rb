#
# Cookbook Name:: yum
# Recipe:: mysql-community
#
# Copyright 2014, Watabe Koki
#
# All rights reserved - Do Not Redistribute
#

cache_dir = "#{Chef::Config[:file_cache_path]}/mysql"

directory cache_dir do
  action :create
end

cache_file = "#{cache_dir}/mysql-community-release-el6-5.noarch.rpm"

remote_file cache_file do
  source "http://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm"
  mode "0775"
  not_if { ::File.exists?(cache_file) }
  action :create
end

execute "yum-localinstall" do
  cwd "#{cache_dir}"
  command "yum -y localinstall #{cache_file}"
  not_if "yum repolist enabled | grep mysql | grep -i community"
  action :run
end
