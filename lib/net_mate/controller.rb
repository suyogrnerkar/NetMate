module NetMate
  class Controller

    def initialize
      @params = {}
    end

    def render erb_name
      erb_name = erb_name.dup
      erb_name << '.html.erb'
      unless erb_name.start_with? '/'
        class_name = self.class.name      
        erb_dir = "#{(class_name[0..(class_name.rindex('Controller').pred)]).downcase}"
        erb_path = "#{ROOT_PATH}/app/views/#{erb_dir}/#{erb_name}"
      else
        erb_path = erb_name
      end
      body = Erubis::Eruby.new(IO.read(erb_path)).result(binding())
      Response.new(body).respond
    end
=begin
    def redirect_to action
      action = action.dup
      if action.include? '/'
        controller, action = action.split('/')
        controller = Object.const_get("#{controller.capitalize}Controller").new
      else
        controller = self.class.new
      end
      controller.instance_variable_set(:@params, @params)
      controller.send(action.to_sym)
    end
=end
  end
end
