# events_emitter

Easy events submissions.

## Usage

```ruby
require 'events_emitter'

EventsEmitter.event(key, value, emitter)
```

Interpretation of key and value depends on your backend. Emitter is a one of `:graphite` (default), `:pixel`, `:redis`.

## Available emitters

### Redis

To configure Redis:

```ruby
EventsEmitter::Redis.config.update(host: "127.0.0.1", port: 6379, db: 1) # default
```

To add 'element_name' element to 'set_name' set invoke:

```ruby
EventsEmitter.event("set_name", "element_name", :redis)
```

### Pixel

To configure pixel emitter:

```ruby
EventsEmitter::Pixel.config.update(url: "//my_host.com/my.gif") # default
```

To request image with 'abcd' fragment (http://my_host.com/my.gif#abcd):

```ruby
EventsEmitter.event("abcd", nil, :pixel)
```

### Graphite

To configure graphite emitter:

```ruby
EventsEmitter::Graphite.config.update(
  graphite_host: 'graphite.example.com',
  graphite_port: 2003,
  memcached_uri: '127.0.0.1:11211',
  keys: ["key1"])
```

Whenever you run

```ruby
EventsEmitter.event("key1", 1, :graphite)
```

EventEmitter will increment the key "key1" by 1 in memcache. To push the changes to graphite run:

```ruby
EventEmitter::Graphite.new.send_batch
```

## Creating new emitter

You can create new emitter:

```ruby
module EventsEmitter
  class Custom
    def record(key, value)
      puts [key, value].join(" => ")
    end
  end
end

# This will print to stdout 'my_key => 2'
EventsEmitter.event("my_key", 2, :custom)
```

## Contributing to events_emitter
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

See LICENSE.txt for further details.

