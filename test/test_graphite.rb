require 'helper'
require 'events_emitter'

class TestGraphite <  Test::Unit::TestCase

  class DalliMock
    def incr(key, count, ttl, default)
      @events ||= {}
      value = @events[key]
      @events[key] = value ? value + count : default
    end

    def get_multi(keys)
      return {} unless @events
      @events.inject({}) do |memo, (key, value)|
        if keys.include? key
          memo.update key => value
        else
          memo
        end
      end
    end
  end

  context "EventsEmitter::Graphite" do

    setup do
      @dalli_mock = DalliMock.new
      @graphite = EventsEmitter::Graphite.new(@dalli_mock)
    end

    context "record" do
      should "send socket messages for every key" do
        values = {
          :one    => "1",
          :two    => "2",
          :three  => "3"
        }

        @dalli_mock.expects(:get_multi).with(["base_key.key1", "base_key.key2"]).returns(values)

        @graphite.base_key = "base_key"
        @graphite.timestamp = "timestamp"
        @graphite.config.update(keys: %w{key1 key2})

        socket = mock()
        socket.expects(:puts).with("one 1 timestamp")
        socket.expects(:puts).with("two 2 timestamp")
        socket.expects(:puts).with("three 3 timestamp")

        Socket.expects(:tcp).with('graphite123.example.com', 2003).yields(socket)

        @graphite.send_batch
      end

      should "increment all the keys and send them" do
        @graphite.base_key = "base_key"
        @graphite.timestamp = "timestamp"

        keys = %w{key1 key2}
        @graphite.config.update(keys: keys)
        keys.each do |key|
          @graphite.record(key, 1)
        end

        socket = mock()
        socket.expects(:puts).with("base_key.key1 1 timestamp")
        socket.expects(:puts).with("base_key.key2 1 timestamp")

        Socket.expects(:tcp).with('graphite123.example.com', 2003).yields(socket)

        @graphite.send_batch
      end

      should "be configurable" do
        old_config = EventsEmitter::Graphite.config.dup
        EventsEmitter::Graphite.config.update(graphite_host: "example.com", graphite_port: 1234)
        Socket.expects(:tcp).with('example.com', 1234).yields(nil)

        @graphite.send_batch
        EventsEmitter::Graphite.config.update(old_config)
      end
    end
  end
end

