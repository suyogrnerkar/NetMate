module NetMate

  @@routes = {}
  def self.routes= r
    @@routes = r
  end

  def self.routes
    @@routes
  end

  class Request

    def initialize
      Routes.new.create_routes
    end

    def call env
      req = Rack::Request.new(env)
      dispatcher = Dispatcher.new(env['PATH_INFO'], env['REQUEST_METHOD'], req.params)
      dispatcher.dispatch
    end

  end  
end