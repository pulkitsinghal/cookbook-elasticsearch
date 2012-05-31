service "elasticsearch" do
  supports :status => true, :restart => true
  action [ :enable ]
end

install_plugin "javascript"
install_plugin "couchdb"
