#
# Cookbook Name:: development-tool
# Recipe:: vim
#
# Copyright 2014, Watabe Koki
#
# All rights reserved - Do Not Redistribute
#

include_recipe "vim::#{node['vim']['install_method']}"
