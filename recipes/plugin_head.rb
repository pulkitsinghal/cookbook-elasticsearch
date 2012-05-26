service "elasticsearch" do
  supports :status => true, :restart => true
  action [ :enable ]
end

install_plugin "mobz/elasticsearch-head"
