#
# Cookbook Name:: collectd
# Recipe:: collectd_web
#
# Copyright 2010, Atari, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "collectd"
include_recipe "apache2"

if platform_family?("debian")
  packages = %w(libhtml-parser-perl liburi-perl librrds-perl libjson-perl)
elsif platform_family?("rhel")
  packages = %w{perl-HTML-Parser perl-URI rrdtool-perl perl-JSON}
end

packages.each do |name|
  package name
end

directory node['collectd']['collectd_web']['path'] do
  owner "root"
  group "root"
  mode "755"
end

bash "install_collectd_web" do
  user "root"
  cwd node['collectd']['collectd_web']['path']
  not_if do
    File.exists?(
      File.join(node['collectd']['collectd_web']['path'], "index.html")
    )
  end
  code <<-EOH
    wget --no-check-certificate -O collectd-web.tar.gz node['collectd']['collectd_web_tarball']
    tar --strip-components=1 -xzf collectd-web.tar.gz
    rm collectd-web.tar.gz
  EOH
end

template "#{node['apache']['dir']}/sites-available/collectd_web.conf" do
  source "collectd_web.conf.erb"
  owner "root"
  group "root"
  mode "644"
end

apache_site "collectd_web.conf"
