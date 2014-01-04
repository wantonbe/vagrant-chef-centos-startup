#
# Cookbook Name:: setting
# Recipe:: stop-services
#
# Copyright 2014, Watabe Koki
#
# All rights reserved - Do Not Redistribute
#
%w{ip6tables iptables messagebus kudzu}.each do |pkg|
  service pkg do
    ignore_failure true
    action [:disable, :stop]
  end
end
