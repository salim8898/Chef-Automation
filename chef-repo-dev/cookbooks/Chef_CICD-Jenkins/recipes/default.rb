#
# Cookbook:: tomcat
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

# Update Server
execute "update-upgrade" do
  command "sudo apt-get update && sudo apt-get upgrade -y"
  action :run
end

# Install OpenJDK
execute "install-OpenJDK" do
  command "sudo apt install default-jdk -y"
  action :run
end
# Create tomcat Group

group 'tomcat' do
  action :create
end

# Create Tomcat User
user 'tomcat' do
  system true
  shell '/bin/false'
  home '/opt/tomcat'
  action :create
  gid 'tomcat'
end

# Downlod tomcat9
remote_file '/tmp/apache-tomcat-9.0.26.tar.gz' do
  source 'http://apachemirror.wuchna.com/tomcat/tomcat-9/v9.0.26/bin/apache-tomcat-9.0.26.tar.gz'
  action :create
end

# Create directory
execute 'mkdir' do
  command "mkdir /opt/tomcat"
  not_if { ::File.exist?('/opt/tomcat') }
end

# Extract and move
execute 'extract-tomcat' do
  command "sudo tar xf /tmp/apache-tomcat-9*.tar.gz -C /opt/tomcat --strip-components=1"
   only_if { ::File.exist?('/opt/tomcat') }
end

# Permission
execute 'perm1' do
  command "sudo chgrp -R tomcat /opt/tomcat"
  only_if { ::File.exist?('/opt/tomcat') }
end

execute 'perm2' do
  command "sudo chmod -R g+r /opt/tomcat/conf"
  only_if { ::File.exist?('/opt/tomcat') }
end

execute 'perm3' do
  command "sudo chmod g+x /opt/tomcat/conf"
  only_if { ::File.exist?('/opt/tomcat') }
end

execute 'perm4' do
  command "sudo chown -R tomcat /opt/tomcat/webapps/ /opt/tomcat/work/ /opt/tomcat/temp/ /opt/tomcat/logs/"
  only_if { ::File.exist?('/opt/tomcat') }
end

# Create tomcat service
template '/etc/systemd/system/tomcat.service' do
  source 'tomcat.service.erb'
  action :create
end

# Daemon reload
execute 'daemon' do
  command "sudo systemctl daemon-reload"
  only_if { ::File.exist?('/etc/systemd/system/tomcat.service') }
end

# Tomcat start
service "tomcat" do
  action [:start, :enable]
  only_if { ::File.exist?('/etc/systemd/system/tomcat.service') }
end

# Change port 8080 to 80
execute 'iptable' do
  command "sudo iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8080"
end

execute 'iptables-save' do
  command 'sudo sh -c "iptables-save > /etc/iptables.rules"'
end

# Download WAR from Nexus
remote_file '/opt/tomcat/webapps/JenkinsWar.war' do
source 'http://salimnexus-1731739187.us-east-1.elb.amazonaws.com/repository/tomcat/com/jenkins/demo/JenkinsWar1/0.01/JenkinsWar1-0.01.war'
action :create
end

# Restart tomcat
service "tomcat" do
  action :restart
  only_if { ::File.exist?('/etc/systemd/system/tomcat.service') }
end


