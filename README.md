DeadDrop [![Gem Version](https://badge.fury.io/rb/dead_drop.svg)](http://badge.fury.io/rb/dead_drop)
========

DeadDrop is a Rails::Engine that allows you to drop content in an anonymous locker only accessible with a randomly generated token.

You can configure when the content should expire and limit the number of total accesses to the content.

DeadDrop can use any Cache::Store that supports the decrement method. This gem has been tested with :file_store, :memory_store, :mem_cache_store and :dalli_store.


Supported Ruby implementations
------------------------------

DeadDrop should work on:

 * JRuby
 * Ruby
 * Rubinius

If you have problems, please enter an issue.

Installation and Configuration
------------------------------

Add `gem 'dead_drop'` to your Gemfile.

If you want to use the Controller option described below add this to your `routes.rb`:
```ruby
mount DeadDrop::Engine, at: "/dead_drop"  # Or any mount point you like
```

You can configure this gem in `initializers/dead_drop.rb`. Here is an example with the default values:
```ruby
DeadDrop.setup do |config|
  config.cache_store = :file_store, 'tmp/cache', { # Just configure any Cache::Store as you'd normally do.
    namespace: 'ddrop',
    compress: true,
    compress_threshold: 2*1024  # 2K
  }
  config.default_access_limit = nil     # How many accesses do you want to allow by default? (nil: no limit)
  config.default_expiration = 24.hours  # When should content expire by default? (nil: no limit)
  config.token_length = 32
  config.default_salt = ''              # Optionally salt tokens before computing the SHA256 when creating the cache key.
  config.cache_key_creation = :base64digest   # When generating the key from the salt+token (SHA256), use this representation.
                                              # When using :file_store on Windows it is recommended to use :hexdigest
                                              # representation in order to avoid collisions due to the case insensitive FS.
end
```

If you want to use the same Cache::Store instance than the rest of your Rails app, just:
```ruby
DeadDrop.setup do |config|
  config.cache_store = Rails.cache
end
```


Usage
-----

**Dropping**
```ruby
csv_content = "col1, col2\n 1.012, John\n 4.332, Mary"
token = DeadDrop.drop(csv_content, filename: "data.csv", expiration: 5.minutes, limit: 1)
```
*csv_content* has been saved in Cache::Store and a url friendly token has been returned.
This token can be used later to access programatically the resource or a url can be generated:
```ruby
url = dead_drop.pick_url(token) # The resource will be rendered when accessed unless it was dropped with
                                # the 'filename' option (useful for storing static html pages, for instance)
url = dead_drop.download_url(token, 'file.dat') # The resource will always be downloaded
```
This url is only useful if you have activated the custom controller in your `routes.rb` (described in installation section)


**Accessing Using Controller**

Just access to the url generated by above helpers which will show the content in the browser or download a file depending on the options you chose.

The url should look similar to `http://domain.com/dead_drop/3vTCwxjRC1oASZgY4MHwbWmQdL9l8Bwb`


**Accessing Programmatically**
```ruby
content = DeadDrop.pick(token)
```
If the token is still valid this hash will be returned: `{:resource=>content, :filename=>name, :mime_type=>mime}`. Else `nil` is returned.

If you just want to check the validity of the token without actually loading the resource:
```ruby
DeadDrop.exists?(token)
```


Helping Out
-----------

If you have a fix you wish to provide, please send a pull request on github.


Author
------

Miguel Canton Cortes, [GitHub](http://github.com/miwelc)


Copyright
---------

MIT Licensed
