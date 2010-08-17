Gem::Specification.new do |s|
  s.name    = 'powerdns_pipe'
  s.version = '1.0.1'
  s.date    = '2010-08-17'
  
  s.summary = "A Ruby abstraction of the PowerDNS pipe backend protocol"
  s.description = "A library to allow easy development of powerdns pipe backend resolvers in Ruby"
  
  s.authors  = ['John Leach']
  s.email    = 'john@johnleach.co.uk'
  s.homepage = 'http://github.com/johnl/powerdns_pipe/tree/master'
  
  s.has_rdoc = true

  s.rdoc_options << '--title' << 'PowerDNS Pipe' <<
    '--main' << 'README.rdoc' <<
    '--line-numbers'

  s.extra_rdoc_files = ["README.rdoc"]

  s.files = Dir.glob("lib/*")
end
