source 'http://rubygems.org'

#Chef have a strong requirement on json version
gem 'json', '= 1.7.7'
gem 'sinatra', '< 1.4.3'

Dir["#{File.dirname(__FILE__)}/bundler.d/*.rb"].each do |bundle|
 # puts "adding custom gem file #{bundle}"
  self.instance_eval(Bundler.read_file(bundle))
end
