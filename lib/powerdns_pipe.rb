module PowerDNS

  # DnsPipe is an abstraction of the Powerdns pipe backend protocol.
  # http://doc.powerdns.com/backends-detail.html
  #
  # It's dead simple to use, see the README for examples
  #
  # Written by John Leach <john@johnleach.co.uk>
  #
  class Pipe
    attr_reader :input, :output, :err, :version_range, :banner

    # Answer object is just used to wrap the block that handles answering
    # queries
    class Answer
      attr_reader :question

      def initialize(pipe, question)
        @pipe = pipe
        @question = question
      end

      def answer(*args)
        @pipe.answer *args
      end

    end

    # Question wraps any type of question line from the server
    class Question < Struct.new(:tag, :name, :qclass, :qtype, :id, :remote_ip_address, :local_ip_address)

      def to_s
        [tag, name, qclass, qtype, id, remote_ip_address, local_ip_address].join("\t")
      end

      def query?
        tag == "Q"
      end

      def axfr?
        tag == "AXFR"
      end
    end

    def initialize(options = {})
      options = { 
        :input => STDIN,
        :output => STDOUT,
        :err => STDERR,
        :version_range => 1..2,
        :banner => "Ruby PowerDNS::Pipe"
      }.merge options

      @input = options[:input]
      @output = options[:output]
      @err = options[:err]
      @version_range = options[:version_range]
      @banner = options[:banner]
    end

    def run!(&query_processor)
      while (line = input.readline) do
        process_line line, query_processor
      end
    rescue EOFError
      err.write "EOF, terminating loop\n"
    end

    def answer(options = {})
      options = {
        :ttl => 3600,
        :id => -1,
        :class => 'IN'
      }.merge options

      respond "DATA", options[:name], options[:class], options[:type], options[:ttl], options[:content]
    end

    private

    def process_line(line, query_processor)
      q = Question.new *line.chomp.split("\t")
      qtypes = { 
        "HELO" => :process_helo,
        "Q" => :process_query,
        "AXFR" => :process_query,
        "PING" => :process_ping
      }

      self.send(qtypes.fetch(q.tag, :process_unknown), q, query_processor)
    end

    def process_helo(q, query_processor)
      if version_range === (q.name.to_i rescue -1)
        respond "OK", banner
      else
        respond "FAIL", banner
      end
    end

    def process_query(q, query_processor)
      answer = Answer.new(self, q)
      begin
        answer.instance_eval &query_processor
        respond "END"
      rescue StandardError => e
        respond "LOG", "Error: #{e.class}: #{e.message}"
        respond "FAIL"
      end

    end

    def process_unknown(q, query_processor)
      respond "LOG", "Unknown Question received: #{q}"
      respond "FAIL"
    end

    def process_ping(q, query_processor)
      respond "END"
    end

    def respond(*args)
      output.write(args.join("\t") + "\n")
      output.flush
    end
  end
end
