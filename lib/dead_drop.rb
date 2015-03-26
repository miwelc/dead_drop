require "dead_drop/engine"

module DeadDrop
  mattr_accessor :packs_prefix
  @@packs_prefix = '_ddrop_packs_'
  mattr_accessor :counter_prefix
  @@counter_prefix = '_ddrop_count_'

  def self.setup
    yield self
  end


  def self.drop(resource, options = {})
    defaults = {expiration: 24.hours, limit: 0, salt: "", filename: ""}
    options = defaults.merge(options)

    data = {resource: resource, filename: options[:filename], mime_type: options[:type]}

    token = ""
    salted_hash = ""
    loop do
      token = SecureRandom.urlsafe_base64(24)
      salted_hash = Digest::SHA256.base64digest(options[:salt]+token)
      break unless Rails.cache.exist?(DeadDrop.packs_prefix+salted_hash)
    end

    pack_key = DeadDrop.packs_prefix+salted_hash
    count_key = DeadDrop.counter_prefix+salted_hash

    Rails.cache.write(pack_key, data, expires_in: options[:expiration])
    Rails.cache.write(count_key, options[:limit]+1, expires_in: options[:expiration], raw: true)

    token
  end

  def self.pick(token, options = {})
    defaults = {ignore_limit: false, salt: ""}
    options = defaults.merge(options)

    salted_hash = Digest::SHA256.base64digest(options[:salt]+token)
    pack_key = DeadDrop.packs_prefix+salted_hash
    count_key = DeadDrop.counter_prefix+salted_hash

    ret = Rails.cache.read(pack_key)

    if options[:ignore_limit] == false
      if 1 == Rails.cache.decrement(count_key, 1, initial: nil)
        Rails.cache.delete(pack_key)
        Rails.cache.delete(count_key)
      end
    end

    ret
  end

end
