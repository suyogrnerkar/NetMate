module NetMate
  class Response

    def initialize body
      @body = body
    end

    def respond
      Rack::Response.new.finish do |res|
        res['Content-Type'] = 'text/html'
        res.status = 200
        res.write @body
      end
    end

    def error
      Rack::Response.new.finish do |res|
        res['Content-Type'] = 'text/html'
        res.status = 404
        res.write @body
      end
    end
    
  end
end