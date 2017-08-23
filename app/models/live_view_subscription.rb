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

  def self.lock(broadcast_job_id)
    redis.set('LiveViewBroadcastJobId', broadcast_job_id)
  end

  def self.unlock
    redis.del('LiveViewBroadcastJobId')
  end

  def self.locked?
    # TODO: Detect if worker is dead
    !!redis.get('LiveViewBroadcastJobId')
  end

  def self.broadcast_job_id
    redis.get('LiveViewBroadcastJobId')
  end

  def self.rerun?
    !!redis.get('LiveViewBroadcastJobRerun')
  end

  def self.rerun
    redis.set('LiveViewBroadcastJobRerun', '1')
  end

  def self.cancel_rerun
    redis.del('LiveViewBroadcastJobRerun')
  end
end
