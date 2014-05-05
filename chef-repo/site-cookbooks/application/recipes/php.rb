#
# Cookbook Name:: application
# Recipe:: php
#
# Copyright 2014, Watabe Koki
#
# All rights reserved - Do Not Redistribute
#
# include_recipe 'php'

include_recipe 'build-essential'
include_recipe 'xml'
include_recipe 'yum-epel' if node['platform_family'] == 'rhel'

%w{ bzip2-devel libc-client-devel curl-devel freetype-devel gmp-devel libjpeg-devel krb5-devel libmcrypt-devel libpng-devel openssl-devel t1lib-devel mhash-devel gd-devel ImageMagick ImageMagick-devel }.each do |pkg|
  package pkg do
    action :install
  end
end

cache_dir = "#{Chef::Config[:file_cache_path]}/php"

directory cache_dir do
  action :create
end

# execute "install-rpm_webtatic" do
#   command "rpm -Uvh http://repo.webtatic.com/yum/centos/5/latest.rpm"
#   action :run
#   not_if "yum list | grep webtatic"
# end
# 
%w{pcre pcre-devel php php-xml}.each do |pkg|
  package pkg do
    action :install
  end
end

cache_file = "#{cache_dir}/rpmforge-release-0.5.2-2.el5.rf.x86_64.rpm"

remote_file cache_file do
  source 'http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.2-2.el5.rf.x86_64.rpm'
  mode "0775"
  action :create
  not_if do
    ::File.exists?(cache_file)
  end
end

# phpbrew
cache_file = "#{cache_dir}/phpbrew"

execute "install-phpbrew" do
  user "root"
  group "root"
  command <<-EOH
    cp #{cache_file} /usr/bin/phpbrew
    phpbrew init
  EOH
  action :nothing
end

remote_file cache_file do
  source "https://raw.github.com/c9s/phpbrew/master/phpbrew"
  mode "0755"
  action :create
  not_if do
    ::File.exists?(cache_file)
  end
  notifies :run, "execute[install-phpbrew]", :immediately
end

phpbrew_root = "/opt/phpbrew"
php_version  = "5.4.12"

execute "install-php" do
  user "root"
  group "root"
  command <<-EOH
    export PHPBREW_ROOT=#{phpbrew_root}
    source /root/.phpbrew/bashrc
    phpbrew install php-#{php_version} +default+mb+fpm+readline+cli+mcrypt -- --with-libdir=lib64
  EOH
  action :nothing
  not_if "phpbrew list | grep #{php_version}"
  notifies :run, "ruby_block[insert_line-etc_bashrc]", :immediately
end

ruby_block "insert_line-etc_bashrc" do
  block do
    file = Chef::Util::FileEdit.new("/etc/bashrc")
    file.insert_line_if_no_match(
      "export PHPBREW_ROOT=#{phpbrew_root}",
      "export PHPBREW_ROOT=#{phpbrew_root}",
    )
    file.insert_line_if_no_match(
      "source #{phpbrew_root}/bashrc",
      "source #{phpbrew_root}/bashrc",
    )
    file.write_file
  end
  action :nothing
end

ruby_block "replace_line-root_phpbrew_init" do
  block do
    file = Chef::Util::FileEdit.new("/root/.phpbrew/init")
    file.search_file_replace_line(
      "export PHPBREW_ROOT=/root/.phpbrew",
      "export PHPBREW_ROOT=/opt/phpbrew",
    )
    file.write_file
  end
  action :run
end

# extension
# execute "switch_php" do
#   user "root"
#   group "root"
#   command <<-EOH
#     export PHPBREW_ROOT=#{phpbrew_root}
#     source /root/.phpbrew/bashrc
#     phpbrew switch php-#{php_version}
#   EOH
#   action :run
# end
# 
execute "phpbrew_ext_install_imagick" do
  user "root"
  group "root"
  command <<-EOH
    export PHPBREW_ROOT=#{phpbrew_root}
    source /root/.phpbrew/bashrc
    phpbrew switch php-#{php_version}
    phpbrew ext install imagick
  EOH
  action :run
  not_if "phpbrew ext list | grep imagick"
end

execute "phpbrew_ext_install_exif" do
  user "root"
  group "root"
  command <<-EOH
    export PHPBREW_ROOT=#{phpbrew_root}
    source /root/.phpbrew/bashrc
    phpbrew switch php-#{php_version}
    phpbrew ext install exif
  EOH
  action :run
  not_if "phpbrew ext list | grep exif"
end

# deploy your sites configuration from the files/ directory in your cookbook
template 'php.ini' do
  path "#{node['php']['conf_dir']}/php.ini"
  source 'php/php.ini.erb'
  owner "root"
  group "root"
  mode 0644
  variables(:directives => node['php']['directives'])
end

execute "copy_init.d/php-fpm" do
  user "root"
  group "root"
  command <<-EOH
    cp -pr #{phpbrew_root}/build/php-#{php_version}/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
    chmod +x /etc/init.d/php-fpm
  EOH
  action :run
  # not_if "diff /etc/init.d/php-fpm #{phpbrew_root}/build/php-#{php_version}/sapi/fpm/init.d.php-fpm"
end

# template 'php-fpm.init' do
#   path '/etc/init.d/php-fpm'
#   source 'php/php-fpm.init.erb'
#   owner "root"
#   group "root"
#   mode 0755
# end

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
