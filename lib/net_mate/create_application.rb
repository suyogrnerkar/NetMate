##
## DO NOT AUTO INDENT
##

module NetMate
  module Generators

    class CreateApplication

      def initialize path
        if path.include? '/'
          @app_path = File.expand_path path[0..(path.rindex('/'))]        
          FileUtils.mkpath @app_path
        else
          @app_path = Dir.pwd
        end
        @app_name = path.split('/').last
      end

      def create_app
        create_skeleton
        write_config_files      
        write_html_pages
        display_output
        puts 'Installing required gems'
        command = "cd #{@app_path}/#{@app_name} && bundle install"
        exec command
      end

      private
        def write_html_pages
          output = ["<!DOCTYPE html>",
                    "<html>",
                    "<head><title>Error</title></head>",
                    "<body>The address you entered does not exist</body>",
                    "</html>"].join("\n")
          IO.write('public/404.html', output)
        end

        def display_output
          puts "Full App path: #{@app_path}/#{@app_name}"
          puts "App name: #{@app_name}"
          puts "Created the following files:"
          Dir['**/*'].each { |file| puts "      #{file}"}
        end

        def write_config_files
          write_database_config
          write_routes_file
          write_gem_file
          write_rackup_file
          write_application_file
        end

        def write_application_file
          output = ["require 'net_mate'",
                    "require File.expand_path('../routes', __FILE__)",
                    "",
                    'Dir["#{File.expand_path(\'../../app\', __FILE__ )}/{controllers,models}/*.rb"].each do |file|',
                    "  require file",
                    "end",
                    "",
                    "ROOT_PATH = File.expand_path('../../', __FILE__)",
                    "",
                    "class Application < NetMate::Request",
                    "end"].join("\n")
          IO.write('config/application.rb', output)
        end

        def write_rackup_file
          output = ["# This file is used by Rack-based servers to start the application.\n",       
                    "require File.expand_path('../config/application',  __FILE__)",
                    "run Application.new"].join("\n")
          IO.write('config.ru', output)
        end

        def write_database_config
          output = ["# MySQL.  Versions 4.1 and 5.0 are recommended.",
                    "#",       
                    "# Install the MYSQL driver",
                    "#   gem install mysql2",  
                    "#",
                    "# Ensure the MySQL gem is defined in your Gemfile",
                    "#   gem 'mysql2'\n",
                    "development:",
                    "  adapter: mysql2",
                    "  encoding: utf8",
                    "  database: #{@app_name}",
                    "  pool: 5",
                    "  username: root",
                    "  password:",
                    "  url: localhost"].join("\n")
          IO.write('config/database.yml', output) 
        end

        def write_routes_file
          output = ["class Routes < NetMate::Routing",
                    "  def create_routes",    
                    "    #examples:",
                    "    #get 'students/show'",
                    "    #post 'students/create",
                    "    #match 'signup', to: 'users#signup', via: 'get'",
                    "    #resources :sessions,     only: [:new, :create]",
                    "  end",
                    "end"].join("\n")
          IO.write('config/routes.rb', output)
        end

        def write_gem_file
          output = ["source 'https://rubygems.org'\n",
                    "gem 'rack'",
                    "gem 'net_mate'",
                    "gem 'mysql2'"].join("\n")
          IO.write('Gemfile', output)
        end

        def create_skeleton
          app_full_path = File.join(@app_path, @app_name)

          FileUtils.mkpath app_full_path
          FileUtils.cd app_full_path
          FileUtils.mkdir %w( app bin config public )

          FileUtils.cd 'app'
          FileUtils.mkdir %w( assets controllers models views )
          FileUtils.cd 'assets'
          FileUtils.mkdir %w( images javascripts stylesheets )
          FileUtils.cd app_full_path

          FileUtils.cd 'config'
          %w( database.yml routes.rb application.rb ).each do |file|
            FileUtils.touch file 
          end
          FileUtils.cd app_full_path

          %w( Gemfile README.md config.ru public/404.html ).each do |file|
            FileUtils.touch file
          end
        end
    end
  end
end