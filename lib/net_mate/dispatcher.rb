module NetMate
  class Dispatcher

    def initialize(url, method, params)
      @url, @method, @params = url, method.downcase, params
    end

    def dispatch
      controller, action = NetMate::routes[[@url, @method]]
      if controller
        controller = Object.const_get("#{controller.capitalize}Controller").new
        controller.instance_variable_set(:@params, @params)
        controller.send(action)
        #controller.send(:render, action.to_s)
      else
        Response.new(IO.read("#{ROOT_PATH}/public/404.html")).error
      end
    end

  end
end