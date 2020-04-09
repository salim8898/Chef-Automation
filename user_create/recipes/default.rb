#
# Cookbook:: user_create
# Recipe:: default
#
# Copyright:: 2020, The Authors, All Rights Reserved.

#userpass=data_bag_item('user_password', 'user1') // for single item call


# create multiple users at a time
data_bag('user_password').each do | item |
  users_data_bag_item = data_bag_item('user_password', item)
  user users_data_bag_item['id'] do
    password users_data_bag_item['password']
    comment 'created from data_bags chef'
  end
end

# add multiple users to Administrators group
data_bag('user_password').each do | item |
  users_data_bag_item = data_bag_item('user_password', item)
  group 'Administrators' do
    action :modify
    members users_data_bag_item['id']
    append true
  end
end

=begin
user node['user_create']['user1'] do
  password ['user_create']['user1_pass']
end

group 'Administrators' do
  action :modify
  members node['user_create']['user1']
  append true
end
=end