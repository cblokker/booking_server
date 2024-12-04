class ComputeAvailableSlots
  SLOT_DURATION = 120.minutes.freeze

  def initialize(coach_id, start_date:, end_date:, cache_service: CacheService.new)
    @coach_id = coach_id
    @start_date = start_date.beginning_of_day
    @end_date = end_date.end_of_day
    @cache_service = cache_service
  end

  def call
    fetch_and_cache_slots
  end

  private

  attr_reader :coach_id, :start_date, :end_date, :cache_service

  def fetch_and_cache_slots
    availability_windows = fetch_availability_windows
    bookings = fetch_bookings.group_by { |booking| booking.start_time.to_date }

    (start_date.to_date..end_date.to_date).each_with_object([]) do |date, all_slots|
      cached_slots = cache_service.fetch_day(coach_id, date)

      if cached_slots
        all_slots.concat(cached_slots)
      else
        computed_slots = compute_slots_for_date(date, availability_windows, bookings[date] || [])
        cache_service.store_day(coach_id, date, computed_slots)
        all_slots.concat(computed_slots)
      end
    end
  end

  def fetch_availability_windows
    AvailabilityWindow
      .where(coach_id: coach_id)
      .where(day_of_week: start_date.wday..end_date.wday)
      .to_a
  end

  def fetch_bookings
    Booking
      .where(coach_id: coach_id)
      .where('start_time < ? AND start_time + INTERVAL \'1 minute\' * duration_minutes > ?', end_date, start_date)
  end

  def compute_slots_for_date(date, availability_windows, bookings_for_date)
    day_of_week = date.wday
    windows_for_day = availability_windows.select { |window| window.day_of_week == day_of_week }

    windows_for_day.flat_map do |window|
      window.intervals.flat_map do |interval|
        compute_slots_for_interval(window, interval, bookings_for_date)
      end
    end
  end

  def compute_slots_for_interval(window, interval, bookings_for_date)
    interval_start = Time.zone.parse(interval['start_time'])
    interval_end = Time.zone.parse(interval['end_time'])

    current_time = interval_start
    slots = []

    bookings_sorted = bookings_for_date.sort_by(&:start_time)

    while current_time + SLOT_DURATION <= interval_end
      slot_end_time = current_time + SLOT_DURATION

      unless slot_conflicts?(current_time, slot_end_time, bookings_sorted)
        slots << {
          start_time: current_time,
          end_time: slot_end_time,
          day_of_week: window.day_of_week,
          coach_id: window.coach_id
        }
      end

      current_time += SLOT_DURATION
    end

    slots
  end

  def slot_conflicts?(slot_start_time, slot_end_time, bookings_sorted)
    bookings_sorted.any? do |booking|
      booking_start = booking.start_time
      booking_end = booking.start_time + booking.duration.minutes

      booking_start < slot_end_time && booking_end > slot_start_time
    end
  end
end