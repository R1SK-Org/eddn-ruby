require 'zlib'
require 'ffi-rzmq'
require 'json'
require 'ffi-rzmq'
require 'zlib'

# Reference docs: https://www.rubydoc.info/github/chuckremes/ffi-rzmq/ZMQ/

module EDDN
  class Subscriber

    attr_reader :eddn_relay, :poll_timeout, :subscriber, :schemas
    attr_accessor :opts

    def initialize(opts = {})
      @opts           = opts.dup
      @opts[:schemas] = opts.try(:[], :schemas) || []
      @schemas        = filter_schemas(@opts[:schemas])
      @eddn_relay     = @opts.try(:eddn_relay) || 'tcp://eddn.edcd.io:9500'
      @poll_timeout   = @opts.try(:timeout)    || 3000
      context         = ZMQ::Context.new
      @subscriber     = context.socket(ZMQ::SUB)
      @subscriber.setsockopt(ZMQ::SUBSCRIBE, "")
    end

    def run!
      while true do
        #begin
          new_msg  ||= ZMQ::Message.new()

          subscriber.connect(eddn_relay)
          Rails.logger.info "Connected to EDDN | Schemas: #{schemas}"

          poller = ZMQ::Poller.new()
          poller.register(subscriber, ZMQ::POLLIN)

          # THE POLL LOOP
          while true do
            # https://www.rubydoc.info/github/chuckremes/ffi-rzmq/ZMQ/Poller#poll-instance_method
            socks = poller.poll(poll_timeout)

            if socks >= 1
              # https://www.rubydoc.info/github/chuckremes/ffi-rzmq/ZMQ/Socket#recvmsg-instance_method
              recv_res = subscriber.recvmsg(new_msg, ZMQ::DONTWAIT)
              break if recv_res == -1
              message  = Zlib::Inflate.inflate(new_msg.copy_out_string)
            elsif socks == 0
              subscriber.disconnect(eddn_relay)
              puts "Disconnected from EDDN (Timeout [#{poll_timeout}])"
              break
            end

            puts message
            # parsed_message = parse(message)
            # puts parsed_message

            #puts " \n -- NEW MESSAGE -- \n" unless parsed_message.nil?
            #puts parsed_message unless parsed_message.nil?

            #ConsolePresenter.log(parsed_message) unless parsed_message.nil? # MAIN OUTPUT
          end

        # rescue SystemExit, Interrupt
        #   subscriber.disconnect(eddn_relay)
        #   raise
        #   break
        # rescue StandardError => e
        #   break
        #   subscriber.disconnect(eddn_relay)
        #   raise e
        #   Rails.logger.error "Disconnected from EDDN (Error #{e.class} raised)"
        #   Rails.logger.error "Error Message: #{e.message}"
        # end
      end
    end

    private

      def filter_schemas(selected_schemas)
        result = eddn_schemas.slice(*selected_schemas)
        result = eddn_schemas if result.empty?
        result.values
      end

      def parse(msg)
        json_msg = Oj.load(msg)
        schema   = json_msg["$schemaRef"]
        json_msg if schemas.include? schema
      end

      def eddn_schemas
        { journal:    "https://eddn.edcd.io/schemas/journal/1",
          commodity:  "https://eddn.edcd.io/schemas/commodity/3",
          outfitting: "https://eddn.edcd.io/schemas/outfitting/2",
          shipyard:   "https://eddn.edcd.io/schemas/shipyard/2" }
      end
  end
end
