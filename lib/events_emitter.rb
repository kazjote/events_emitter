require 'events_emitter/base'
require 'events_emitter/redis'
require 'events_emitter/graphite'
require 'events_emitter/pixel'

module EventsEmitter
  def self.event(key, value = 1, type = :graphite)
    Base.new(type).event(key, value)
  end
end

