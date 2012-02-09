module EventsEmitter
  class Base
    def initialize(type)
      @backend = constantize("EventsEmitter::#{type.to_s.capitalize}").new
    rescue NameError => e
      raise ArgumentError.new("Unsupported emitter: #{type}")
    end

    def event(key, value = 1)
      @backend.record(key, value)
    end

    protected

    # Taken from ActiveSupport::Inflector
    def constantize(camel_cased_word)
      names = camel_cased_word.split('::')
      names.shift if names.empty? || names.first.empty?

      constant = Object
      names.each do |name|
        constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
      end
      constant
    end
  end
end

