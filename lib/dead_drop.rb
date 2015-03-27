require "dead_drop/engine"

module DeadDrop

  class << self
    mattr_accessor :cache_prefix
    mattr_accessor :ignore_head_requests
    mattr_accessor :head_requests_count
    mattr_accessor :default_access_limit
    mattr_accessor :default_expiration
    mattr_accessor :default_salt

    self.cache_prefix = '_ddrop'
    self.default_salt = ""
    self.default_access_limit = 0
    self.default_expiration = 24.hours
    self.ignore_head_requests = false
    self.head_requests_count = false
  end

  def self.setup(&block)
    yield self
  end


  def self.drop(resource, options = {})
    options = { expiration: DeadDrop.default_expiration,
                limit: DeadDrop.default_access_limit,
                salt: DeadDrop.default_salt,
                filename: "",
                mime_type: nil
              }.merge(options)

    data = {resource: resource, filename: options[:filename], mime_type: options[:mime_type]}

    token = ""
    loop do
      token = SecureRandom.urlsafe_base64(24)
      break unless DeadDrop.exists?(token, salt: options[:salt])
    end

    packs_key = DeadDrop.packs_key(token, options[:salt])
    count_key = DeadDrop.count_key(token, options[:salt])

    Rails.cache.write(packs_key, data, expires_in: options[:expiration])
    Rails.cache.write(count_key, options[:limit]+1, expires_in: options[:expiration], raw: true)

    token
  end

  def self.pick(token, options = {})
    defaults = {ignore_limit: false, salt: DeadDrop.default_salt}
    options = defaults.merge(options)

    packs_key = DeadDrop.packs_key(token, options[:salt])
    count_key = DeadDrop.count_key(token, options[:salt])

    ret = Rails.cache.read(packs_key)

    if options[:ignore_limit] == false
      if 1 == Rails.cache.decrement(count_key, 1, initial: nil)
        Rails.cache.delete(packs_key)
        Rails.cache.delete(count_key)
      end
    end

    ret
  end

  def self.exists?(token, options = {})
    defaults = { salt: DeadDrop.default_salt }
    options = defaults.merge(options)

    packs_key = DeadDrop.packs_key(token, options[:salt])
    Rails.cache.exist?(packs_key)
  end

  private

  def self.packs_key(token, salt)
    salted_hash = Digest::SHA256.base64digest(salt+token)
    DeadDrop.cache_prefix+'_packs_'+salted_hash
  end

  def self.count_key(token, salt)
    salted_hash = Digest::SHA256.base64digest(salt+token)
    DeadDrop.cache_prefix+'_count_'+salted_hash
  end

end
