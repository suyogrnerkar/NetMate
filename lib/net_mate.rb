require 'rack'
require 'erubis'
require 'active_support/inflector'
Dir["#{File.expand_path('..', __FILE__ )}/net_mate/*.rb"].each do |file|
    require file
end