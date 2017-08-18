class LiveViewSubscription
  def self.redis
    # TODO: Compatibility with Redises not from Sidekiq
    Sidekiq.redis { |c| c }
  end

  def self.create(uuid)
    redis.sadd('LiveViewSubscriptions', uuid)
  end

  def self.set(uuid, *args)
    create(uuid)
    redis.hmset(uuid, *args)
  end

  class << self
    ['id', 'parser', 'source', 'query'].each do |attr|
      define_method(attr) do |uuid|
        redis.hget(uuid, attr)
      end

      define_method("#{attr}=") do |uuid, value|
        set(uuid, attr, value)
      end
    end
  end

  def self.destroy(uuid)
    redis.del(uuid)
    redis.del('LiveViewSubscriptions', uuid)
  end

  def self.destroy_all
    uuids = redis.smembers('LiveViewSubscriptions')
    uuids.each do |uuid|
      destroy(uuid)
    end
    redis.del('LiveViewSubscriptions')
  end

  def self.all
    output = {}
    uuids = redis.smembers('LiveViewSubscriptions')
    uuids.each do |uuid|
      output.merge!({uuid => redis.hgetall(uuid)})
    end
    output
  end
end
