$:.unshift File.join(File.dirname(__FILE__), '../lib')
$:.unshift File.join(File.dirname(__FILE__), '../spec')

require 'powerdns_pipe'
include PowerDNS
