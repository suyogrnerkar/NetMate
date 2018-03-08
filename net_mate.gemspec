Gem::Specification.new do |s|
  s.platform     =  Gem::Platform::RUBY
  s.name         =  'net_mate'
  s.version      =  '1.0.0'
  s.executables  << 'net_mate'
  s.summary      =  'MVC Web application framework'
  s.description  =  'NetMate is a framework created to facilitate Web ' +
                    'Development using Ruby. The framework is an MVC ' +
                    'framework which provides basic functionality to ' +
                    'create a web application.'
  s.license      =  'MIT'
  s.authors      =  ['Sharang Dashputre', 'Suyog Nerkar', 'Sachin Wagh']
  s.email        =  ['sharang.dashputre@weboniselab.com', 
                     'suyog.nerkar@weboniselab.com',
                     'sachin.wagh@weboniselab.com']
  s.homepage     =  ''
  s.require_path =  'lib'
  s.files        =  Dir["{bin,lib}/**/*"]

  s.required_ruby_version     = '>= 2.0.0'
  s.required_rubygems_version = '>= 1.8.11'
  

  s.add_runtime_dependency 'rack'
  s.add_runtime_dependency 'erubis'
  s.add_runtime_dependency 'activesupport'
  s.add_runtime_dependency 'mysql2'
end