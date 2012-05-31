service "elasticsearch" do
  supports :status => true, :restart => true
  action [ :enable ]
end

####
# No point in using this, we don't just want to make sure that the server is up
# We also want to be sure that all the data has been loaded back up by cloud-aws
# and there is simply no hook for that that I know of right now :(
####
#
#execute "Ensure Restart" do
#   command "sudo service elasticsearch status -v | grep 'running with PID'"
#   retries 20   #Will check 20 times, every 2 seconds for 40 seconds total
#end

# The CURL operation that creates the river config, should only run if
# it doesn't see a configured metadata document in the _river index already
bash "configure couchdb river" do
  user 'root'
  notifies :restart, resources(:service => 'elasticsearch')
  only_if "curl -XGET -k 'https://localhost:9443/_river/#{node.elasticsearch['plugin']['river']['couchdb']['db']}/_meta' | grep -q '\"exists\":false'"
  code <<-EOS
    echo curl -XPUT -k 'https://#{node.elasticsearch['adminUsername']}:#{node.elasticsearch['adminPassword']}@localhost:9443/_river/#{node.elasticsearch['plugin']['river']['couchdb']['db']}/_meta' -d '{
      "type" : "couchdb",
      "couchdb" : {
        "protocol"           : #{node.elasticsearch['plugin']['river']['couchdb']['protocol']},
        "host"               : #{node.elasticsearch['plugin']['river']['couchdb']['host']},
        "port"               : #{node.elasticsearch['plugin']['river']['couchdb']['port']},
        "no_verify"          : #{node.elasticsearch['plugin']['river']['couchdb']['no_verify']},
        "user"               : #{node.elasticsearch['plugin']['river']['couchdb']['user']},
        "password"           : #{node.elasticsearch['plugin']['river']['couchdb']['password']},
        "db"                 : #{node.elasticsearch['plugin']['river']['couchdb']['db']},
        "ignore_attachments" : #{node.elasticsearch['plugin']['river']['couchdb']['ignore_attachments']},
        "filter"             : null
      },
      "index" : {
        "index"        : #{node.elasticsearch['plugin']['river']['couchdb']['index']},
        "type"         : #{node.elasticsearch['plugin']['river']['couchdb']['type']},
        "bulk_size"    : #{node.elasticsearch['plugin']['river']['couchdb']['bulk_size']},
        "bulk_timeout" : #{node.elasticsearch['plugin']['river']['couchdb']['bulk_timeout']}
      }
    }'
    curl -XPUT -k 'https://#{node.elasticsearch['adminUsername']}:#{node.elasticsearch['adminPassword']}@localhost:9443/_river/#{node.elasticsearch['plugin']['river']['couchdb']['db']}/_meta' -d '{
      "type" : "couchdb",
      "couchdb" : {
        "protocol"           : #{node.elasticsearch['plugin']['river']['couchdb']['protocol']},
        "host"               : #{node.elasticsearch['plugin']['river']['couchdb']['host']},
        "port"               : #{node.elasticsearch['plugin']['river']['couchdb']['port']},
        "no_verify"          : #{node.elasticsearch['plugin']['river']['couchdb']['no_verify']},
        "user"               : #{node.elasticsearch['plugin']['river']['couchdb']['user']},
        "password"           : #{node.elasticsearch['plugin']['river']['couchdb']['password']},
        "db"                 : #{node.elasticsearch['plugin']['river']['couchdb']['db']},
        "ignore_attachments" : #{node.elasticsearch['plugin']['river']['couchdb']['ignore_attachments']},
        "filter"             : null
      },
      "index" : {
        "index"        : #{node.elasticsearch['plugin']['river']['couchdb']['index']},
        "type"         : #{node.elasticsearch['plugin']['river']['couchdb']['type']},
        "bulk_size"    : #{node.elasticsearch['plugin']['river']['couchdb']['bulk_size']},
        "bulk_timeout" : #{node.elasticsearch['plugin']['river']['couchdb']['bulk_timeout']}
      }
    }'
  EOS
end
