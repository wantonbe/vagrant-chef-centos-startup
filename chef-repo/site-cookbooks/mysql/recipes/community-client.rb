#
# Cookbook Name:: mysql
# Recipe:: community-client
#
# Copyright 2014, Watabe Koki
#
# All rights reserved - Do Not Redistribute

include_recipe 'yum::mysql-community'

%w{mysql-community-client mysql-community-devel mysql-community-libs mysql-community-libs-compat}.each do |srv|
  package "#{srv}" do
    action :install
  end
end
