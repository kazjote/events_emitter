require 'dalli'

module EventsEmitter
  class Graphite

    attr_accessor :base_key, :storage
    attr_writer :timestamp

    def initialize(storage = Dalli::Client.new(Graphite.config[:memcached_uri]))
      self.storage = storage
      self.base_key = "ofw.rails.#{hostname}"
    end

    def hostname
      @hostname ||= %x(hostname -s).strip
    end

    def send_batch
      now = timestamp

      composed_keys = config[:keys].map{ |e| compose_key(e) }
      values = storage.get_multi(composed_keys)

      Socket.tcp(config[:graphite_host], config[:graphite_port]) do |socket|
        values.each do |key, value|
          socket.puts("#{key} #{value.to_i} #{now}")
        end
      end
    end

    def record(key, amount)
      storage.incr(compose_key(key), amount, nil, amount)
    end

    def compose_key(key)
      "#{base_key}.#{key}"
    end

    def timestamp
      @timestamp || Time.now.utc.to_i
    end

    def filtering_steps
      FILTERING_STEPS
    end

    def config
      self.class.config
    end

    def self.config
      @config ||= {
        graphite_host: 'graphite123.example.com',
        graphite_port: 2003,
        memcached_uri: '127.0.0.1:11211',
        keys: ["key1"] }
    end
  end
end
