class Rock::HardJob
  include Sidekiq::Job

  def perform(coach_id, start_date = Time.zone.now, end_date = 1.month.from_now)
    service = ComputeAvailableSlots.new(coach_id, start_date: start_date, end_date: end_date)
    available_slots = service.call

    # Cache the results in Redis
    Redis.current.set(
      redis_key(coach_id, start_date, end_date),
      available_slots.to_json,
      ex: 24.hours.to_i
    )
  end

  private

  def redis_key(coach_id, start_date, end_date)
    "available_slots:coach:#{coach_id}:#{start_date.to_date}:#{end_date.to_date}"
  end
end
