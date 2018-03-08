require 'yaml'
require 'mysql2'

module NetMate
  
  class Connection   

    attr_reader :db_config
    def initialize path = nil
      path ||= "#{ROOT_PATH}/config/database.yml"
      @db_config = YAML.load_file(path)['development']
    rescue
      abort 'Please check if you are in the proper Application directory!'
    end

    def connect
      Mysql2::Client.new @db_config
    end

    def self.disconnect dbh
      dbh.close if dbh
    end

  end
end