require 'spec_helper'

describe Pipe::Question do

  it "should accept a v1 query" do
    q = Pipe::Question.new 'Q', 'example.com', 'IN', 'ANY', '-1', '8.8.8.8'
    q.query?.should == true
    q.axfr?.should == false
    q.tag.should == "Q"
    q.name.should == "example.com"
    q.qclass.should == "IN"
    q.qtype.should == "ANY"
    q.id.should == "-1"
    q.remote_ip_address.should == "8.8.8.8"
    q.local_ip_address.should == nil
  end

  it "should accept a v2 query" do
    q = Pipe::Question.new 'Q', 'example.com', 'IN', 'ANY', '-1', '8.8.8.8', '127.0.0.1'
    q.query?.should == true
    q.axfr?.should == false
    q.tag.should == "Q"
    q.name.should == "example.com"
    q.qclass.should == "IN"
    q.qtype.should == "ANY"
    q.id.should == "-1"
    q.remote_ip_address.should == "8.8.8.8"
    q.local_ip_address.should == "127.0.0.1"
  end

  it "should accept an axfr" do
    q = Pipe::Question.new 'AXFR', '99'
    q.query?.should == false
    q.axfr?.should == true
    q.name.should == "99" # Was originally a bug, but now we have to support it!
  end

end
