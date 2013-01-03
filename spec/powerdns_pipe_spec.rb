$:.unshift File.join(File.dirname(__FILE__), '../lib')
$:.unshift File.join(File.dirname(__FILE__), '../spec')

require 'powerdns_pipe'
include PowerDNS

describe Pipe do

  it "should use STDIN, STDOUT and STDERR by default" do
    pipe = Pipe.new
    pipe.input.should == STDIN
    pipe.output.should == STDOUT
    pipe.err.should == STDERR
  end

  it "should read from the input object" do
    input = mock(:input)
    pipe = Pipe.new :input => input
    input.should_receive :readline
    pipe.run! { }
  end

  it "should write to the output object" do
    output = mock(:output)
    input = StringIO.new("\n")
    pipe = Pipe.new :input => input, :output => output, :err => StringIO.new
    output.should_receive(:write).at_least(:once)
    output.should_receive(:flush).at_least(:once)
    pipe.run! { }
  end

  describe "questions" do
    before :each do
      @input = StringIO.new
      @output = StringIO.new
      @err = StringIO.new
      @pipe = Pipe.new :input => @input, :output => @output, :err => @err
    end

    it "should answer a PING" do
      @input.string = "Q\tPING\n"
      @pipe.run! { }
      @output.string.should == "END\n"
    end

    (1..2).each do |version|
      it "should answer a HELO for version #{version}" do
        @input.string = "HELO\t#{version}"
        @pipe.run! { }
        @output.string.should =~ /^OK\t/
      end
    end

    it "should answer a question with a remote ip address (version 1)" do
      @input.string = "Q\texample.com\tIN\tANY\t-1\t8.8.8.8"
      @pipe.run! { answer :name => "example.com", :type => "A", :ttl => 300, :content => "192.0.43.10" }
      @output.rewind
      @output.string.should == "DATA\texample.com\tIN\tA\t300\t-1\t192.0.43.10\nEND\n"
    end

    it "should answer a question with a local ip address (version 2)" do
      @input.string = "Q\texample.com\tIN\tANY\t-1\t8.8.8.8\t127.0.0.1"
      @pipe.run! { answer :name => "example.com", :type => "A", :ttl => 300, :content => "192.0.43.10" }
      @output.rewind
      @output.string.should == "DATA\texample.com\tIN\tA\t300\t-1\t192.0.43.10\nEND\n"
    end

    it "should answer an axfr"

  end
end
