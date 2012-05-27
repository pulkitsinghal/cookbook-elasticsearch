# Install ElasticSearch plugin
#
define :install_plugin do

  bash "/usr/local/bin/plugin -install #{node.elasticsearch[:plugin][params[:name].intern][:url]}" do
    user "root"
    code "/usr/local/bin/plugin -install #{node.elasticsearch[:plugin][params[:name].intern][:url]}"

    notifies :restart, resources(:service => 'elasticsearch')

    not_if do
      Dir.entries("#{node.elasticsearch[:dir]}/elasticsearch-#{node.elasticsearch[:version]}/plugins/").any? do |entry|
        begin
          puts "Does #{entry} match the plugin name for #{params[:name]} ???"
          puts node.elasticsearch[:plugin][params[:name].intern][:name].eql? entry
          node.elasticsearch[:plugin][params[:name].intern][:name].eql? entry
        rescue
          false
        end
      end
    end

  end

end
