service "elasticsearch" do
  supports :status => true, :restart => true
  action [ :enable ]
end

# If the keystoreFilename is provided then deploy it to jetty
bash "deploy any existing server certificate" do
  user 'root'
  code <<-EOS
  mv /tmp/"#{node.elasticsearch['plugin']['jetty']['keystoreFilename']}" "#{node.elasticsearch[:conf_path]}"/"#{node.elasticsearch['plugin']['jetty']['keystoreFilename']}"
  EOS
  not_if { ::File.exists?("#{node.elasticsearch[:conf_path]}/#{node.elasticsearch['plugin']['jetty']['keystoreFilename']}") }
end

# If the file with keystoreFilename, still doesn't exist then create it on the fly
bash "create a new server certificate" do
  user 'root'
  cwd "#{node.elasticsearch[:conf_path]}"
  code <<-EOH
  echo 'openssl genrsa -des3 -passout pass:password -out jetty.key.pem 2048'
  openssl genrsa -des3 -passout pass:#{node.elasticsearch['plugin']['jetty']['keystorePassword']} -out jetty.key.pem 2048"

  echo 'openssl req -new -x509 -key jetty.key.pem -passin pass:password -days 3650 -subj "/CN=sub.domain.com" -out jetty.crt.pem'
  openssl req -new -x509 -key jetty.key -passin pass:#{node.elasticsearch['plugin']['jetty']['keystorePassword']} -days 3650 -subj "/CN=#{node[:ipaddress]}" -out jetty.crt.pem

  echo 'openssl pkcs12 -export -out jetty.keystore.p12 -passout pass:password -inkey jetty.key.pem -passin pass:password -in jetty.crt.pem -certfile jetty.crt.pem -name "jetty"'
  openssl pkcs12 -export -out #{node.elasticsearch['plugin']['jetty']['keystoreFilename']} -passout pass:#{node.elasticsearch['plugin']['jetty']['keystorePassword']} -inkey jetty.key.pem -passin pass:#{node.elasticsearch['plugin']['jetty']['keystorePassword']} -in jetty.crt.pem -certfile jetty.crt.pem -name "#{node.elasticsearch['plugin']['jetty']['alias']}"
  EOH
  not_if { ::File.exists?("#{node.elasticsearch[:conf_path]}/#{node.elasticsearch['plugin']['jetty']['keystoreFilename']}") }
end

# Create SSL-specific config file for elasticsearch-jetty plugin
template "jetty-ssl.xml" do
  path "#{node.elasticsearch[:conf_path]}/jetty-ssl.xml"
  source "jetty-ssl.xml.erb"
  owner node.elasticsearch[:user] and group node.elasticsearch[:user] and mode 0755
  only_if { node.elasticsearch[:plugin][:jetty][:https] }
end

# Backup the existing ES config file
bash "backup ES config" do
  user 'root'
  code <<-EOS
    cp "#{node.elasticsearch[:conf_path]}/elasticsearch.yml" "#{node.elasticsearch[:conf_path]}/elasticsearch.yml.pre.jetty.backup"
  EOS
  not_if { ::File.exists?("#{node.elasticsearch[:conf_path]}/elasticsearch.yml.pre.jetty.backup") }
end

# Create XML config file for elasticsearch-jetty plugin
template "jetty.xml" do
  path "#{node.elasticsearch[:conf_path]}/jetty.xml"
  source "jetty.xml.erb"
  owner node.elasticsearch[:user] and group node.elasticsearch[:user] and mode 0755
  not_if { ::File.exists?("#{node.elasticsearch[:conf_path]}/elasticsearch.yml.pre.jetty.backup") }
end

# Create YML config file sub-section for elasticsearch-jetty plugin to later append to the existing ES config file
template "elasticsearch.yml.jetty" do
  path "#{node.elasticsearch[:conf_path]}/elasticsearch.yml.jetty"
  source "elasticsearch.yml.jetty.erb"
  owner node.elasticsearch[:user] and group node.elasticsearch[:user] and mode 0755
  not_if { ::File.exists?("#{node.elasticsearch[:conf_path]}/elasticsearch.yml.jetty") }
end

# Append the plugin's configured file to the actual config file for ES
bash "setup jetty config" do
  user 'root'
  code <<-EOS
    curl -o "#{node.elasticsearch[:conf_path]}/keystore" https://raw.github.com/sonian/elasticsearch-jetty/master/config/keystore
    curl -o "#{node.elasticsearch[:conf_path]}/realm.properties" https://raw.github.com/sonian/elasticsearch-jetty/master/config/realm.properties
    echo '
################################## Security ##################################' >> "#{node.elasticsearch[:conf_path]}/elasticsearch.yml"
    cat "#{node.elasticsearch[:conf_path]}/elasticsearch.yml.jetty" >> "#{node.elasticsearch[:conf_path]}/elasticsearch.yml"
  EOS
  not_if { ::File.read("#{node.elasticsearch[:conf_path]}/elasticsearch.yml").match(/^Switch to jetty transport/) }
end

install_plugin "jetty"