#
# Cookbook Name:: application
# Recipe:: composer
#
# Copyright 2014, Watabe Koki
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'application::php'

cache_dir = "#{Chef::Config[:file_cache_path]}/composer"

directory cache_dir do
  action :create
end

cache_file = "#{cache_dir}/composer.phar"

remote_file cache_file do
  source 'https://getcomposer.org/installer'
  mode "0775"
  action :create
  not_if do
    ::File.exists?(cache_file)
  end
end

execute "install-composer" do
  cwd "#{cache_dir}"
  command "php #{cache_file}"
  action :nothing
end

link "/usr/local/bin/composer" do
  to "#{cache_dir}/composer.phar"
  action :create
  only_if do
    ::File.exists?("#{cache_dir}/composer.phar")
  end
end
