#
# Cookbook Name:: development-tool
# Recipe:: git
#
# Copyright 2014, Watabe Koki
#
# All rights reserved - Do Not Redistribute
#
cache_dir = "#{Chef::Config[:file_cache_path]}"

directory cache_dir do
  action :create
end

%w{make curl-devel gcc openssl-devel expat-devel cpan gettext asciidoc xmlto git}.each do |pkg|
  package "#{pkg}" do
    action :install
  end
end

git "#{cache_dir}/git" do
  repository "git://github.com/git/git.git"
  reference "master"
  action :sync
  not_if do
    ::File.exists?("/usr/local/bin/git")
  end
  notifies :run, "execute[install-git]", :immediately
end

execute "install-git" do
  cwd "#{cache_dir}/git"
  command <<-EOH
    make configure
    ./configure --prefix=/usr/local
    make all doc
    make install install-doc
  EOH
  action :nothing
end
