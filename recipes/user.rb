# Copyright 2015 Sergey Bahchissaraitsev

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

group node['airflow']['group'] do
  gid node['airflow']['group_id']
  action :create
  not_if "getent group #{node['airflow']['group']}"
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

user node['airflow']['user'] do
  comment "Airflow user"
  home node["airflow"]["user_home_directory"]
  uid node['airflow']['user_id']
  gid node['airflow']['group']
  system true
  shell "/bin/bash"
  manage_home true
  action :create
  not_if "getent passwd #{node['airflow']['user']}"
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

group node['hops']['group'] do
  gid node['hops']['group_id']
  action :create
  not_if "getent group #{node['hops']['group']}"
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

group node['hops']['group'] do
  action :modify
  members ["#{node['airflow']['user']}"]
  append true
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

hopsworksUser = "glassfish"
if node.attribute? "hopsworks"
    if node["hopsworks"].attribute? "user"
       hopsworksUser = node['hopsworks']['user']
    end
end

#
# Glassfish user needs to read the airflow dags, so we add it to the airflow group
# However, we need to do it before installing the glassfish server, as glassfish caches the groups
# that the glassfish user is a member of - requiring a reboot. To avoid the reboot, add the glassfish
# user to the airflow group here.
#
group node['airflow']['group'] do
  action :modify
  members [hopsworksUser]  
  append true
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end
