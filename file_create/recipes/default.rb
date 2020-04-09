#
# Cookbook:: file_create
# Recipe:: default
#
# Copyright:: 2020, The Authors, All Rights Reserved.

file 'c:\temp\dependences' do
  content 'check if this works'
end

include_recipe 'user_create'