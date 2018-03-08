require 'fileutils'
require 'active_support/inflector'

module NetMate
  module Generators
    class ModelGenerator	

      def initialize model, columns
        @model = model.dup
        @columns = columns
      end

      def generate_model     
        flag = false
        cur_dir = Dir.pwd
        while cur_dir != "/" do
          if Dir.exist? 'app'              
            FileUtils.cd 'app'
            if Dir.exist? 'models'          
              call_create_table
              FileUtils.cd 'models'
              model_rb = ActiveSupport::Inflector.underscore "#{@model}.rb"
              output = "class #{ActiveSupport::Inflector.camelize(@model)} < NetMate::Model\nend"
              IO.write model_rb, output
              puts "Created app/models/#{model_rb}"
              flag = true
              break
            else
              abort 'ERROR: app/models folder does not exist'
            end
          else
            cur_dir = File.expand_path '..', Dir.pwd
            FileUtils.cd cur_dir  
          end
        end
        abort "ERROR: please move to the application folder" unless flag
      end

      private
      
      def create_table table_data 
        attributes = table_data[:columns].map { |k, v| "#{k.to_s} #{convert(v)}" }.join(', ')
        table_attributes = "id INT AUTO_INCREMENT ," << attributes << ", PRIMARY KEY (id)" 
        dbh = Connection.new("#{Dir.pwd}/../config/database.yml").connect
          # Create Table in database 
          dbh.query "CREATE TABLE #{table_data[:table_name]}(#{table_attributes})"
        rescue Exception => e
          puts e
          puts e.backtrace.join("\n")
        else
          puts "Table #{table_data[:table_name]} was created successfully."
        ensure
          # disconnect from server
          Connection.disconnect dbh
        end

        def convert val
          case val
          when 'string' 
            'VARCHAR(80)'
          when 'integer'
            'INT'
          when 'date'
            'DATE'
          when 'float'
            'DECIMAL(20,10)'
          when 'datetime'
           'DATETIME' 
         when 'text'
           'TEXT'
         else 'boolean'
           'BOOLEAN'      
         end
       end

       def supported_datatype? given_type 
        supported_datatypes = ['boolean', 'string', 'integer', 'date',
         'datetime', 'text', 'float']
         if !supported_datatypes.include? given_type
          abort "Unsupported datatype: #{given_type}\nSupported_datatypes are:\n#{supported_datatypes}"
        end
        true
      end

      def call_create_table 
        table_data = {}
        table_data[:columns] = {}
        @columns.each do |column|
          colm_name, colm_type = column.downcase.split ':'
          if supported_datatype? colm_type
            table_data[:columns][colm_name.to_sym] = colm_type
          end
        end
        table_data[:table_name] = ActiveSupport::Inflector.tableize(@model)
        create_table table_data
        true
      end
    end
  end
end