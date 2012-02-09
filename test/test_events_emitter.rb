require 'helper'
require 'events_emitter'

class TestEventsEventsEmitter < Test::Unit::TestCase
  context "EventsEmitter::Base" do
    setup do
      EventsEmitter.unstub(:event)
    end

    context "event" do
      should "raise exception when type not supported" do
        assert_raise(ArgumentError) do
          EventsEmitter.event("key", "value", :noexists)
        end
      end

      should "call Graphite when type is empty" do
        graphite = mock()
        EventsEmitter::Graphite.expects(:new).returns(graphite)
        graphite.expects(:record).with("key", "value")
        EventsEmitter.event("key", "value")
      end

      should "call Graphite with value 1 when type and value are empty" do
        graphite = mock()
        EventsEmitter::Graphite.expects(:new).returns(graphite)
        graphite.expects(:record).with("key", 1)
        EventsEmitter.event("key")
      end

      should "call Graphite when type is graphite" do
        graphite = mock()
        EventsEmitter::Graphite.expects(:new).returns(graphite)
        graphite.expects(:record).with("key", "value")
        EventsEmitter.event("key", "value")
      end
    end
  end
end
