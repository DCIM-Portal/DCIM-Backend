class LiveViewSubscription
  def self.redis
    # TODO: Compatibility with Redises not from Sidekiq
    Sidekiq.redis { |c| c }
  end

  def self.create(id)
    redis.sadd('LiveViewSubscriptions', id)
  end

  def self.set(id, *args)
    create(id)
    redis.hmset(id, *args)
  end

  class << self
    ['name', 'parser', 'source', 'query'].each do |attr|
      define_method(attr) do |id|
        redis.hget(id, attr)
      end

      define_method("#{attr}=") do |id, value|
        set(id, attr, value)
      end
    end
  end

  def self.destroy(id)
    redis.del(id)
    redis.srem('LiveViewSubscriptions', id)
  end

  def self.destroy_all
    ids = redis.smembers('LiveViewSubscriptions')
    ids.each do |id|
      destroy(id)
    end
    redis.del('LiveViewSubscriptions')
  end

  def self.all
    output = {}
    ids = redis.smembers('LiveViewSubscriptions')
    ids.each do |id|
      output.merge!({id => redis.hgetall(id)})
    end
    output
  end
end
