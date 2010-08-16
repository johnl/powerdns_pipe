Gem::Specification.new do |s|
  s.name    = 'powerdns_pipe'
  s.version = '1.0'
  s.date    = '2010-08-16'
  
  s.summary = "A Ruby abstraction of the PowerDNS pipe backend protocol"
  s.description = "A library to allow easy development of powerdns pipe backend resolvers in Ruby"
  
  s.authors  = ['John Leach']
  s.email    = 'john@johnleach.co.uk'
  s.homepage = 'http://github.com/johnl/powerdns_pipe/tree/master'
  
  s.has_rdoc = false

  s.files = Dir.glob("lib/*")
end
