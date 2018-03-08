require 'mysql2'
require 'active_support/inflector'

module NetMate 
  class Model
    
    @@columns = []

    def make_accessors
      self.class.class_eval do
        @@columns.each do |col|
          if col != 'id'
            attr_accessor col.to_sym
          else
            attr_reader :id
          end
        end
      end
    end

    def update
      dbh = Connection.new.connect
      cols = @@columns.reject { |e| e == 'id' }
      attributes = cols.each_with_index.map { |c, i| "#{c} = '#{self.send(c.to_sym)}'" }.join(', ')
      dbh.query("UPDATE #{find_name} SET #{attributes} WHERE id = #{@id} ")
    end

    def get_columns
      dbh = Connection.new.connect
      dbh.query("desc #{find_name}").each do |row|
          @@columns << row.values[0]
      end      
      Connection.disconnect dbh
    end

    def initialize args = {}
      @@columns = []
      get_columns
      make_accessors
      args.each { |k ,v| instance_variable_set("@#{k}".to_sym, v) }
    end

    def save
      table = find_name
      dbh = Connection.new.connect
      values = []
      cols = @@columns.reject { |e| e == 'id' }
      cols.each do |col|
        values << self.send(col.to_sym)
      end
      values = values.map { |v| "'#{v}'" }.join(', ')
      dbh.query "INSERT INTO #{table}(#{cols.join(',')}) VALUES (#{values})"
      rescue
        puts "An error occurred while saving into the database."
      else 
        puts "New record was saved/added successfully."
      ensure
        Connection.disconnect dbh
    end

    def find_name
      ActiveSupport::Inflector.tableize(self.class.name)      
    end

    def self.all
      return find_by_sql("SELECT * FROM #{ActiveSupport::Inflector.tableize(self.name)}")
    end

    def self.find(id)
      id = id.to_i
      dbh = Connection.new.connect
      res = self.new
      dbh.query("SELECT * FROM #{ActiveSupport::Inflector.tableize(self.name)} WHERE ID = #{id}").each do |row|
        row.each { |k ,v| res.instance_variable_set("@#{k}".to_sym, v) }
      end
      rescue 
      ensure
        Connection.disconnect dbh
        return res
    end

    def self.find_by_sql(sql_query)
      dbh = Connection.new.connect
      res = []  
      dbh.query(sql_query).each_with_index do |row, i|
        res[i] = self.new
        row.each { |k, v| res[i].instance_variable_set("@#{k}".to_sym, v) }
      end
      rescue 
        puts "An error occurred"
      ensure
        Connection.disconnect dbh
        return res
    end

    def self.find_by(col_name, value)
      return find_by_sql("SELECT * FROM #{ActiveSupport::Inflector.tableize(self.name)} WHERE #{col_name} = '#{value}'")
    end

    def destroy
      dbh = Connection.new.connect
      dbh.query "DELETE FROM #{find_name} WHERE id = #{instance_variable_get(:@id)}"
      rescue 
        puts "An error occurred"
      ensure
        Connection.disconnect dbh
    end
  end
end