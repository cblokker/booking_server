class CacheService
  DEFAULT_TTL = 24.hours.freeze

  def initialize(redis_client: Redis.current)
    @redis = redis_client
  end

  def fetch_day(coach_id, date)
    key = day_cache_key(coach_id, date)
    cached_value = @redis.get(key)
    cached_value ? JSON.parse(cached_value) : nil
  end

  def fetch_range(coach_id, start_date, end_date)
    keys = (start_date..end_date).map { |date| day_cache_key(coach_id, date) }
    @redis.mget(keys).compact.map { |value| JSON.parse(value) }.flatten
  end

  def store_day(coach_id, date, slots, ttl: DEFAULT_TTL)
    key = day_cache_key(coach_id, date)
    @redis.set(key, slots.to_json, ex: ttl)
  end

  def delete_day(coach_id, date)
    key = day_cache_key(coach_id, datxe)
    @redis.del(key)
  end

  def delete_range(coach_id, start_date, end_date)
    keys = (start_date..end_date).map { |date| day_cache_key(coach_id, date) }
    @redis.del(*keys)
  end

  private

  def day_cache_key(coach_id, date)
    "available_slots:#{coach_id}:#{date}"
  end
end
