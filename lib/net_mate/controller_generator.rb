require 'active_support/inflector'
require 'tempfile'

module NetMate
  module Generators
    class ControllerGenerator	

      def initialize controller, actions
        @controller = controller.dup
        @actions = actions
      end

      def generate_controller       
        cur_dir = Dir.pwd
        flag = false
        while cur_dir != '/' do 
          if Dir.exist? 'app'              
            FileUtils.cd 'app'
            if Dir.exist? 'controllers'          
              FileUtils.cd 'controllers'
              controller_rb = "#{ActiveSupport::Inflector.tableize(@controller)}_controller.rb"
              File.open(controller_rb, 'w') do |file|  
                puts "Created app/controllers/#{controller_rb}"
                @controller =  ActiveSupport::Inflector.pluralize(@controller)                
                file.puts "class #{ActiveSupport::Inflector.camelize(@controller)}Controller < NetMate::Controller\n\n"
                @actions.each do |action|
                  file.puts "  def #{action}\n  end\n\n"
                end
                file.puts 'end'
              end
              flag = true
              break
            else
              abort 'ERROR: app/controllers folder does not exist'
            end
          else
            cur_dir = File.expand_path '..', Dir.pwd
            FileUtils.cd cur_dir        
          end            
        end
        abort 'ERROR: please move to the application folder' unless flag
        unless @actions.empty?
          create_views
          create_routes
        end
      end

      private

      def create_views
        FileUtils.cd File.expand_path '..', Dir.pwd
        if Dir.exist? 'views'
          FileUtils.cd 'views'
          @controller = ActiveSupport::Inflector.tableize(@controller)
          FileUtils.mkpath @controller
          FileUtils.cd @controller
          @actions.each do |action|
            action_html_erb = action.dup << '.html.erb'                    
            IO.write action_html_erb, "This is #{action_html_erb} file."
            puts "Created app/views/#{@controller}/#{action_html_erb}"
          end
        else
          abort 'ERROR app/views folder does not exist '
        end
      end

        #move to config/routes.rb and make entries in routes.rb for generated actions
        def create_routes
          FileUtils.cd File.expand_path '../../..', Dir.pwd    
          FileUtils.cd 'config'
          temp = Tempfile.new 'temp_routes'
          File.open('routes.rb', 'r').each_line do |line|            
            temp.puts line
            if line =~ /def\s+create_routes/
              @actions.each do |action|  
                route_entry = "#{ActiveSupport::Inflector.tableize(@controller)}/#{action}"       
                temp.puts "#{' ' * 4}get '#{route_entry}'"
                puts "Created route #{route_entry}"
              end
            end
          end
          temp.close
          FileUtils.mv temp.path, 'routes.rb'
        end
      end
    end
  end