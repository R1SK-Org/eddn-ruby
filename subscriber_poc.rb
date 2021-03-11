require 'ffi-rzmq'
require 'zlib'
require 'json'

# Reference docs: https://www.rubydoc.info/github/chuckremes/ffi-rzmq/ZMQ/
module EDDN
  class SubscriberPoc

    attr_reader :relay, :sock_timeout, :acc, :poller, :context, :subscriber

    def initialize(accumulator = [])
      @relay        = 'tcp://eddn.edcd.io:9500'
      @sock_timeout = 60000 # 1 minute
      @acc          = accumulator
    end

    def run!
      while true do
        begin
          connect
          set_poll

          while true do
            res = poll_routine

            if res == -1
              break
            end
          end
        rescue => e
          puts "Loop error: #{e.message}"
          disconnect!(99, "Error in the loop!")
          break
        end
      end
    end

    def connect
      prepare
      subscriber.connect(relay)
      puts "Connected to EDDB at #{relay}"
    end

    def set_poll
      @poller = ZMQ::Poller.new()
      @poller.register(subscriber, ZMQ::POLLIN)
      puts "Poller created!"
    end

    def poll_routine
      poll_socks = poller.poll(sock_timeout)

      if poll_socks
        parse_message
      else
        disconnect!(98, "Timeout (#{sock_timeout})")
        return -1
      end
    end

    def parse_message
      new_msg  = ZMQ::Message.new()

      # https://www.rubydoc.info/github/chuckremes/ffi-rzmq/ZMQ/Socket#recvmsg-instance_method
      recv_res = subscriber.recvmsg(new_msg, ZMQ::DONTWAIT)

      unless recv_res == -1
        decomp_msg = Zlib::Inflate.inflate(new_msg.copy_out_string)
        json_msg   = ::JSON.parse(decomp_msg)

        #acc.push json_msg
        puts "Message Received: #{json_msg}"
      else
        disconnect!(recv_res)
      end
    end

    def disconnect!(errno, errmsg = "")
      puts "Disconnected from EDDN! | ERRNO: #{errno} | ERRMSG: #{errmsg}"
      subscriber.disconnect(relay)
    end

    def prepare
      @context    = ZMQ::Context.new
      @subscriber = context.socket(ZMQ::SUB)
      @subscriber.setsockopt(ZMQ::SUBSCRIBE, "")
    end
  end
end
