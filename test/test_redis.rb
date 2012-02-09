require 'helper'
require 'json'
require 'events_emitter'

class TestEventsEmitter < Test::Unit::TestCase
  context "EventsEmitter::Redis" do
    setup do
      @backend = EventsEmitter::Redis.new
    end

    context "redis" do
      should "cache the storage" do
        ::Redis.expects(:new).returns("storage").once
        2.times { @backend.storage }
      end

      should "send the key value" do
        storage = mock()
        storage.expects(:sadd).with("key", "value".to_json)

        @backend.expects(:storage).returns(storage)

        @backend.record("key", "value")
      end

      should "allow configuring redis" do
        EventsEmitter::Redis.config.update(host: "new.host", port: 1234, db: 5)

        ::Redis.expects(:new).with do |hash|
          hash[:host] == "new.host" && hash[:port] == 1234 && hash[:db] == 5
        end

        @backend.storage
      end
    end
  end
end
