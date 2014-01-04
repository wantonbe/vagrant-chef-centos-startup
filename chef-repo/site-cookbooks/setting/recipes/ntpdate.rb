#
# Cookbook Name:: setting
# Recipe:: ntpdate
#
# Copyright 2014, Watabe Koki
#
# All rights reserved - Do Not Redistribute
#
cron 'ntpdate' do
  minute '0'
  hour '5'
  day '*'
  month '*'
  weekday '*'
  command "/usr/sbin/ntpdate -bs ntp.nict.jp"
  action :create
end
