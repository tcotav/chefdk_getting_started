#
# Cookbook Name:: chefdk_getting_started
# Recipe:: default
#
# Copyright (C) 2014 
#
# 
#

include_recipe 'apt'
include_recipe 'tomcat'

# not really how Chef handles a war file but do so only for this demo
cookbook_file "/var/lib/tomcat6/webapps/punter.war" do
  source "punter.war"
  mode 00744
  owner 'root'
  group 'root'
end


