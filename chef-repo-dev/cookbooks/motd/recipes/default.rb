#
# Cookbook:: motd
# Recipe:: default
#
# Copyright:: 2020, The Authors, All Rights Reserved.

file 'C:\Windows\Temp' do
  content "This is the test Motd displaying system hostname <%= node['fqdn'] %>"
end