require "dead_drop/engine"

module DeadDrop

  class << self
    mattr_accessor :cache_store
    mattr_accessor :default_access_limit
    mattr_accessor :default_expiration
    mattr_accessor :default_salt
    mattr_accessor :token_length
    mattr_accessor :cache_key_creation
    mattr_accessor :cache

    self.cache_store = :file_store, 'tmp/cache', {
      namespace: 'ddrop',
      compress: true,
      compress_threshold: 2*1024 # 2K
    }
    self.default_salt = ''
    self.default_access_limit = nil
    self.default_expiration = 24.hours
    self.token_length = 32
    self.cache_key_creation = :base64digest
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

    options[:limit] = 0 if options[:limit].nil? || options[:limit] < 0

    data = {resource: resource, filename: options[:filename], mime_type: options[:mime_type]}

    token = ""
    loop do
      token = SecureRandom.urlsafe_base64((DeadDrop.token_length*3)/4)
      break unless DeadDrop.exists?(token, salt: options[:salt])
    end

    packs_key = DeadDrop.packs_key(token, options[:salt])
    count_key = DeadDrop.count_key(token, options[:salt])

    DeadDrop.cache.write(packs_key, data, expires_in: options[:expiration])
    DeadDrop.cache.write(count_key, options[:limit]+1, expires_in: options[:expiration], raw: true)

    token
  end

  def self.pick(token, options = {})
    defaults = {ignore_limit: false, salt: DeadDrop.default_salt}
    options = defaults.merge(options)

    packs_key = DeadDrop.packs_key(token, options[:salt])
    count_key = DeadDrop.count_key(token, options[:salt])

    ret = DeadDrop.cache.read(packs_key)

    if options[:ignore_limit] == false
      if 1 == DeadDrop.cache.decrement(count_key, 1, initial: nil)
        DeadDrop.cache.delete(packs_key)
        DeadDrop.cache.delete(count_key)
      end
    end

    ret
  end

  def self.delete(token, options = {})
    defaults = {salt: DeadDrop.default_salt}
    options = defaults.merge(options)

    packs_key = DeadDrop.packs_key(token, options[:salt])
    count_key = DeadDrop.count_key(token, options[:salt])
    DeadDrop.cache.delete(packs_key)
    DeadDrop.cache.delete(count_key)
  end

  def self.exists?(token, options = {})
    defaults = { salt: DeadDrop.default_salt }
    options = defaults.merge(options)

    packs_key = DeadDrop.packs_key(token, options[:salt])
    DeadDrop.cache.exist?(packs_key)
  end

  private

  def self.packs_key(token, salt)
    '_packs_'+Digest::SHA256.send(DeadDrop.cache_key_creation, salt+token)
  end

  def self.count_key(token, salt)
    '_count_'+Digest::SHA256.send(DeadDrop.cache_key_creation, salt+token)
  end

end
