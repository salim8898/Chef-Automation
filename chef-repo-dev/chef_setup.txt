###Chef Setup##

# Reuquire 3 machines as follows
1.Chef_Server 2.Chef_Worstation+Jenkins 3.Cline-node



1.Login to check server and change hostname
change hostname in /etc/hostname
chefserver
add this into /etc/hosts as well also update chef_workstation and chef-node hosts.

sudo sysctl kernel.hostname=chefserver
Check your current hostname with hostname -f


2.Download and install Chef server package
 https://packages.chef.io/files/stable/chef-server/12.18.14/ubuntu/16.04/chef-server-core_12.18.14-1_amd64.deb
dpkg -i chef-server-core_12.18.14-1_amd64.deb


3.Initial Chef configuration
chef-server-ctl reconfigure
browse chef ip in web browser and follow steps mentined in portal to install opscode


4.Create admin user for chef-opscode
cd $HOME
sudo chef-server-ctl user-create jenkinsadmin jenkinsadmin jenkinsadmin selfieblue@gmail.com admin123 -f jenkinsadmin.pem

This will create private key to access chef-server will require during configuring chef_workstation

5. Open chef_server ip in web browser
login with creditals we just created in cli
username:jenkinsadmin
pass:admin123

6. New Organization
full name:development.chefio.lab
short name:dev

7.click on Administration tab
Organization->dev->reset validate key(this is one time setup only so save in safe place)-> download

8.click on dev and generate knife config and save (this will also used to setup workstation)

9. click on policy and create 2 Environments (dev-env and prod-env)

10. Restart below services
sudo chef-server-ctl status
sudo chef-server-ctl stop
sudo chef-server-ctl start

sudo opscode-manage-ctl status
sudo opscode-manage-ctl stop
sudo opscode-manage-ctl start

###############################################################################
##Chef Workstation Setup##
1.Download and install chefworkstatio
wget https://packages.chef.io/files/stable/chef-workstation/0.8.7/ubuntu/16.04/chef-workstation_0.8.7-1_amd64.deb
dpkg -i chef-workstation_0.8.7-1_amd64.deb

mkdir /chef-repo-dev
mkdir /chef-repo-dev/.chef
mkdir /chef-repo-dev/.chef/syntaxcache
sudo mkdir /chef-repo-dev/.chef/syntaxcache
mkdir /chef-repo-dev/.chef/trusted_certs
chmod -R 777 /chef-repo-dev-

paste jenkinsadmin.pem to /chef-repo-dev/.chef/ (from chef_server /root/jenkinsadmin.pem)
paste dev-validator.pem to /chef-repo-dev/.chef/
paste knife.rb to /chef-repo.dev/.chef

paste chefserver.crt to /chef-repo-dev/.chef/trusted_certs (from chef_server: /var/opt/opscode/nginx/ca/SERVER_HOSTNAME.crt)

2. Validation part
knife ssl fetch (this will copty chefserver.crt from chef_server if not present)
knife ssl check (this will check he connectiviy using values in knife.rb to connect correct chef_server)
If this shows 'Successfully verified cerificate from chefserver' means you all set to go ahead

#######################################################
Chef Client setup
1.We need user with root privileges to login this client from chefworkstation and prform bootstrap
Login to client
useradd -m jenkinsadmin
passwd admin123

vim /etc/sudoers
# User privilege specification
root    ALL=(ALL:ALL) ALL
jenkinsadmin ALL=(ALL:ALL) NOPASSWD:ALL
# Members of the admin group may gain root privileges
%admin ALL=(ALL) ALL
jenkinsadmin ALL=(ALL) ALL

vim /etc/hosts
ip chefserver


2. Run bootstrap from chefworkstation
Login to chefworkstation

chef generate cookbook cookbooks/apache-install
Code commited to git repo for reference
chef generate template cookbooks/apache-install/ index.html
kinfe cookbook upload apache-install
knife cookbook list

cd /chef-repo-dev(here knife command will work)
knife bootstrap 52.66.202.44 -x jenkinsadmin -P admin123 --sudo --node-name node-client-node1 --run-list 'recipe[apache-install]'
Above command will bootstrap node and run cookbook mentioned in runlist

####################################################################################
	Jenkins Installation and stups in chefworkstation server
1. Need to install java first before jenkinsadmin and supporting sofwares

sudo apt install openjdk-8-jre
sudo update-alternatives --config java

Simply follow steps from -->https://wiki.jenkins.io/display/JENKINS/Installing+Jenkins+on+Ubuntu

wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install jenkins
sudo apt-get install aptitude
 
 
 
 vim  /etc/apache2/sites-available/jenkins.conf

 <VirtualHost *:80>
    ServerAdmin webmaster@localhost
    ServerName chefwork
    ServerAlias chefwork
    ProxyRequests Off
    <Proxy *>
        Order deny,allow
        Allow from all
    </Proxy>
    ProxyPreserveHost on
    ProxyPass / http://localhost:8080/ nocanon
    AllowEncodedSlashes NoDecode
</VirtualHost>

And then save and exit
–>Add ServerName to Apache2.conf
$ sudo vi /etc/apache2/apache2.conf

If Nginx dosen't work follow this cmds
add chefwork<machine hostname in last line of apache configuration file>
sudo vi /etc/apache2/apache2.conf
ServerName chefserver
Remove default site-enable
sudo rm /etc/apache2/sites-enabled/000-default.conf
sudo a2ensite jenkins
sudo apache2ctl restart

Restart chefwork means jenkins server





hit jenkins url in browser
cat /var/lib/jenkins/secrets/initialAdminPassword
set username jenkinsadmin
pass:admin123

On the lef panel, click on Managee Jenkins –> Configure Global Security
Tick on Enable security and in tab : Security Realm : select Unix user/group database
Scroll down to the bottom, in tab : Authentication : select Matrix-base security
Add user “jenkinsadmin” and select all of priviledges to this user but user Anonymous select only View priviledge on item Read Only

if you messed up jenkins and unable to login due to security
/var/lib/jenkins/config.xml
<useSecurity>true</useSecurity>		 change true to false
sudo service jenkins restart

insall php plugin
continue from how to use unix/users 3) Tick on Enable security and in tab : Security Realm : select Unix user/group database
 