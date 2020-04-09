#
# Cookbook:: apache
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

# Update Server
execute "update-upgrade" do
  command "sudo apt-get update && sudo apt-get upgrade -y"
  action :run
end

# Install apache
package "apache2" do
  action :install
end

# Change page content
template "/var/www/html/index.html" do
  source 'index.html.erb'
end

# Enable and start apache2
service "apache2" do
  action [:enable, :start]
end
