service "elasticsearch" do
  supports :status => true, :restart => true
  action [ :enable ]
end

# Install the dependency plugin so that we may use js for filtering _changes feed
install_plugin "javascript"

# Install the plugin that supports rivers between CouchDB and ES
install_plugin "couchdb"