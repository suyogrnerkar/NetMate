require File.expand_path('../connection', __FILE__)

module NetMate
  module Generators
    class DatabaseGenerator

      def initialize
        iterate
        @db_config = Connection.new("#{Dir.pwd}/database.yml").db_config
      end

      def in_cur_dir? dir  
         in_cur_dir = []
         Dir.entries('.').each do |entry| 
           if File.directory? File.join('.', entry) and !(entry =='.' || entry == '..')
             in_cur_dir << entry    
           end
         end
         in_cur_dir.include? dir
      end

      def check_and_create_database        
        dbh = Connection.new("#{Dir.pwd}/database.yml").connect
        # connect to the MySQL server
        # Create Table in database 
        if dbh.query "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '#{@db_config["database"]}'" 
          puts "USING EXISTING DATABASE #{@db_config['database']}" 
        end
      rescue
          puts "Creating new Database #{@db_config['database']}"
          create_database()
        ensure
        # disconnect from server
        Connection.disconnect dbh
      end

      private
        def iterate
          cur_dir = Dir.pwd
          while cur_dir != '/' do
            if in_cur_dir? 'config'  
              FileUtils.cd 'config'
              if !File.exist? 'database.yml'
                abort "ERROR: app/config folder does not exist"
              else
                return
              end
            else
              cur_dir = File.expand_path '..' , Dir.pwd
              FileUtils.cd cur_dir
            end 
          end  
          abort 'Could not find database.yml'
        end


        def create_database() 
          dbh = Mysql2::Client.new(database: 'INFORMATION_SCHEMA',
                                   username: @db_config['username'],
                                   password: @db_config['password'],
                                   host: @db_config['url'])
          dbh.query "CREATE DATABASE #{@db_config['database']}" 
          puts "Database #{@db_config['database']} is created successfully."
          Connection.disconnect dbh 
          
          #-------------------modified-------------#
          rescue 
            puts "\n######################################################################"
            puts "#   There was an error while connecting to the Mysql.                #"               
            puts "#   Please check if you have configured the database.yml             #"            
            puts "#   File can be found in config/ of your application directory.      #"
            puts "#   Make sure you setup proper Username and Password for database.   #"
            puts "######################################################################\n\n"
          #----------------------------------------#          
        end
    end
  end
end