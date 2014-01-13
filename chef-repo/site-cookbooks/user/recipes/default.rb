#
# Cookbook Name:: user
# Recipe:: default
#
# Copyright 2014, Watabe Koki
#
# All rights reserved - Do Not Redistribute
#

node['user']['search_groups'].each do |search_group|
  user_manage search_group do
    action :create
  end
end
