require 'helper'
require 'events_emitter'

class TestPixel < Test::Unit::TestCase
  context "EventsEmitter::Pixel" do
    setup do
      @backend = EventsEmitter::Pixel.new
    end

    should "generate proper url" do
      fragment = "m=this+is+the+message&one=1&two=2"

      assert_equal(
        "//tracking.example.com/ofw.gif?#{fragment}",
        @backend.url(fragment)
      )
    end

    context "record" do
      should "call an url XXX" do
        @backend.stubs(:url).with("params").returns("//pixel.url/my_pixel.html?a=1&b=2")

        http_mock = mock()

        Net::HTTP.expects(:new).with("pixel.url", 80).returns(http_mock)
        Net::HTTP::Get.expects(:new).with("/my_pixel.html?a=1&b=2").returns("request")

        http_mock.expects(:read_timeout=).with(1)
        http_mock.expects(:request).with("request")

        @backend.record("params", {})
      end

      should "have a TimeOut exception but not raise it when notifier is specified" do
        exception_notifier = mock
        EventsEmitter::Pixel.config.update(exception_notifier: exception_notifier)
        Net::HTTP.any_instance.expects(:request).raises(Timeout::Error)

        expected_arguments = [instance_of(Timeout::Error), instance_of(URI::HTTP)]
        exception_notifier.expects(:notify).with(*expected_arguments)

        result = @backend.record("message", {})
        assert_equal(false, result)
      end

      should "have a TimeOut exception and raise it when notifier is not specified" do
        EventsEmitter::Pixel.config.update(exception_notifier: nil)
        Net::HTTP.any_instance.expects(:request).raises(Timeout::Error)
        assert_raise(Timeout::Error) do
          @backend.record("message", {})
        end
      end
    end
  end
end

