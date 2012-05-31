default.elasticsearch[:plugin][:javascript][:version] = "1.1.0"
default.elasticsearch[:plugin][:javascript][:name] = "lang-javascript"
default.elasticsearch[:plugin][:javascript][:url] = "elasticsearch/elasticsearch-lang-javascript/#{node.elasticsearch[:plugin][:javascript][:version]}"

default.elasticsearch[:plugin][:couchdb][:version] = "1.1.0"
default.elasticsearch[:plugin][:couchdb][:name] = "river-couchdb"
default.elasticsearch[:plugin][:couchdb][:url] = "elasticsearch/elasticsearch-river-couchdb/#{node.elasticsearch[:plugin][:couchdb][:version]}"
