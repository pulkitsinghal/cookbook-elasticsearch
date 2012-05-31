service "elasticsearch" do
  supports :status => true, :restart => true
  action [ :enable ]
end

# Install the dependency plugin so that we may use js for filtering _changes feed
install_plugin "javascript"

# Install the plugin that supports rivers between CouchDB and ES
install_plugin "couchdb"

# The CURL operation that creates the river config, should only run if
# it doesn't see a configured metadata document in the _river index already
bash "configure couchdb river" do

  user 'root'

  code <<-EOS
    curl -XPUT 'localhost:9200/_river/#{node.elasticsearch['plugin']['river']['couchdb']['db']}/_meta' -d '{
      "type" : "couchdb",
      "couchdb" : {
        "protocol" : "#{node.elasticsearch['plugin']['river']['couchdb']['protocol']}",
        "host" : "#{node.elasticsearch['plugin']['river']['couchdb']['host']}",
        "port" : "#{node.elasticsearch['plugin']['river']['couchdb']['port']}",
        "no_verify" : "#{node.elasticsearch['plugin']['river']['couchdb']['no_verify']}",
        "user" : "#{node.elasticsearch['plugin']['river']['couchdb']['user']}",
        "password" : "#{node.elasticsearch['plugin']['river']['couchdb']['password']}",
        "db" : "#{node.elasticsearch['plugin']['river']['couchdb']['db']}",
        "ignore_attachments" : "#{node.elasticsearch['plugin']['river']['couchdb']['ignore_attachments']}",
        "filter" : null
      },
      "index" : {
        "index" : "#{node.elasticsearch['plugin']['river']['couchdb']['index']}",
        "type" : "#{node.elasticsearch['plugin']['river']['couchdb']['type']}",
        "bulk_size" : "#{node.elasticsearch['plugin']['river']['couchdb']['bulk_size']}",
        "bulk_timeout" : "#{node.elasticsearch['plugin']['river']['couchdb']['bulk_timeout']}"
      }
    }'
  EOS

  only_if "curl -XGET 'https://localhost:9200/_river/#{node.elasticsearch['plugin']['river']['couchdb']['db']}/_meta' | grep -q 'IndexMissingException'"

end
