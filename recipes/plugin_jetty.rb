service "elasticsearch" do
  supports :status => true, :restart => true
  action [ :enable ]
end

install_plugin "sonian/elasticsearch-jetty/#{node.elasticsearch[:version]}"
