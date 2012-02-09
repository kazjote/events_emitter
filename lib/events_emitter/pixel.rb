require "net/http"

module EventsEmitter
  class Pixel

    def record(fragment, _)
      pixel_url = URI.parse("http:#{url(fragment)}")

      http = Net::HTTP.new(pixel_url.host, pixel_url.port)
      http.read_timeout = timeout

      request   = Net::HTTP::Get.new(pixel_url.request_uri)
      response  = http.request(request)

      return true
    rescue Timeout::Error => e
      notifier = self.class.config[:exception_notifier]
      if notifier
        notifier.notify(e, pixel_url)
        return false
      else
        raise e
      end
    end

    def url(fragment)
      "#{self.class.config[:url]}?#{fragment}"
    end

    def timeout
      1
    end

    def self.config
      @config ||= { url: "//tracking.example.com/ofw.gif" }
    end
  end
end
