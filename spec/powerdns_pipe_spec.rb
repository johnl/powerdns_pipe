require 'spec_helper'

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

    it "should answer an axfr" do
      @input.string = "AXFR\texample.com\tIN\tANY\t-1\t8.8.8.8\t127.0.0.1"
      @pipe.run! { answer :name => "example.com", :type => "A", :ttl => 300, :content => "192.0.43.10" }
      @output.string.should =~ /^DATA\texample.com/
    end

    it "should ignore answers that don't match the question type" do
      @input.string = "Q\texample.com\tIN\tSOA\t-1\t8.8.8.8"
      @pipe.run! { answer :name => "example.com", :type => "A", :ttl => 300, :content => "192.0.43.10" }
      @output.rewind
      @output.string.should == "END\n"
    end

    it "should pass through all answers when question type is ANY" do
      @input.string = "Q\texample.com\tIN\tANY\t-1\t8.8.8.8"
      @pipe.run! { answer :name => "example.com", :type => "A", :ttl => 300, :content => "192.0.43.10" }
      @output.rewind
      @output.string.should == "DATA\texample.com\tIN\tA\t300\t-1\t192.0.43.10\nEND\n"
    end


  end

  describe "#answer" do
    before :each do
      @input = StringIO.new
      @output = StringIO.new
      @err = StringIO.new
      @pipe = Pipe.new :input => @input, :output => @output, :err => @err
      @question = Pipe::Question.new
      @question.qtype = "A"
      @answer = Pipe::Answer.new @pipe, @question
    end

    it "should write a valid data line" do
      @answer.answer :ttl => 300, :id => 99, :class => 'IN', :name => 'example.com', :type => 'A', :content => '127.0.0.1'
      @output.string.should == "DATA\texample.com\tIN\tA\t300\t99\t127.0.0.1\n"
    end

  end
end
