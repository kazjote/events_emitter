require 'redis'
require 'json'

module EventsEmitter
	class Redis
		def storage
      return @storage if @storage

      opts = {
        :host => self.class.config[:host],
        :port => self.class.config[:port],
        :db   => self.class.config[:db]
      }

			@storage = ::Redis.new(opts)
		end

		def record(key, value)
      storage.sadd(key, value.to_json)
		end

    def get(key)
      storage.smembers(key).map do |e|
        JSON.parse(e)
      end
    end

    def self.config
      @config ||= { host: "127.0.0.1", port: 6379, db: 1 }
    end
	end
end
