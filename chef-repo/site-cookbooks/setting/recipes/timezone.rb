#
# Cookbook Name:: setting
# Recipe:: timezone
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
template '/etc/sysconfig/clock' do
  source 'etc/sysconfig/clock.erb'
  notifies :run, 'execute[timezone_update]', :immediately
end

execute 'timezone_update' do
  command 'cp -pr /usr/share/zoneinfo/Asia/Tokyo /etc/localtime'
  action :nothing
end
