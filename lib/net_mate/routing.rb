module NetMate

  class Routing

    def get path
      match path, to: path.tr('/','#'), via: 'get'
    end

    def post path
      match path, to: path.tr('/','#'), via: 'post'
    end

    def match path, options
      path = path == '/' ? path : "/#{path}"
      controller, action = options[:to].split('#')
      NetMate::routes[[path, options[:via]]] = [controller, action]
    end

    def resources controller, options = { only: [:new, :create, :edit, :update, :show, :index] }
      options[:only].each do |action|
        action = action.to_s
        controller = controller.to_s
        path = "/#{controller}/#{action}"
        method = ['create', 'update'].include?(action) ? 'post' : 'get' 
        NetMate::routes[[path, method]] = [controller, action]      
      end
    end    

  end
end