service "elasticsearch" do
  supports :status => true, :restart => true
  action [ :enable ]
end

# Create config file for elasticsearch-jetty plugin
template "jetty.xml" do
  path "#{node.elasticsearch[:conf_path]}/jetty.xml"
  source "jetty.xml.erb"
  owner node.elasticsearch[:user] and group node.elasticsearch[:user] and mode 0755
end

# Create config file for elasticsearch-jetty plugin
template "elasticsearch.yml.jetty" do
  path "#{node.elasticsearch[:conf_path]}/elasticsearch.yml.jetty"
  source "elasticsearch.yml.jetty.erb"
  owner node.elasticsearch[:user] and group node.elasticsearch[:user] and mode 0755
end

# Append the plugin's configured file to the actual config file for ES
bash "setup jetty config" do
  user 'root'
  code <<-EOS
    curl -o "#{node.elasticsearch[:conf_path]}/keystore" https://github.com/sonian/elasticsearch-jetty/raw/master/config/keystore
    echo '
################################## Security ##################################' >> "#{node.elasticsearch[:conf_path]}/elasticsearch.yml"
    cat "#{node.elasticsearch[:conf_path]}/elasticsearch.yml.jetty" >> "#{node.elasticsearch[:conf_path]}/elasticsearch.yml"
  EOS
  not_if { ::File.read("#{node.elasticsearch[:conf_path]}/elasticsearch.yml").match(/^Switch to jetty transport/) }
end

install_plugin "jetty"
