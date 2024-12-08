require 'active_support/time'

module Service
  class SlotGenerator
    DEFAULT_SLOT_DURATION = ::User::DEFAULT_BOOKING_TYPE[:duration_minutes].minutes
    DEFAULT_START_DATE = Date.today.beginning_of_week
    DEFAULT_END_DATE = Date.today.beginning_of_week + 1.month 

    def initialize(window:, timezone:, start_date: DEFAULT_START_DATE, end_date: DEFAULT_END_DATE)
      @window = window
      @timezone = timezone
      @start_date = start_date
      @end_date = end_date
    end

    def generate_slots
      relevant_dates.flat_map do |date|
        generate_slots_for_day(date)
      end
    end

    private

    attr_reader :window, :timezone, :start_date, :end_date

    def relevant_dates
      @relevant_dates ||= (start_date..end_date).select { |date| date.wday == window[:day_of_week] }
    end

    def generate_slots_for_day(date)
      window[:intervals].flat_map do |interval|
        generate_slots_for_interval(interval, date)
      end
    end

    def generate_slots_for_interval(interval, date)
      start_time = parse_time_on_date(interval['start_time'], date)
      end_time = parse_time_on_date(interval['end_time'], date)

      [].tap do |slot_records|
        while start_time + DEFAULT_SLOT_DURATION <= end_time
          slot_records << build_slot(start_time)
          start_time += DEFAULT_SLOT_DURATION
        end
      end
    end

    def parse_time_on_date(time_string, date)
      ActiveSupport::TimeZone[timezone].parse("#{date} #{time_string}").utc
    end

    def build_slot(start_time)
      {
        start_time: start_time,
        end_time: start_time + DEFAULT_SLOT_DURATION,
        coach_id: window[:coach_id],
        availability_window_id: window[:id],
        booked: false
      }
    end
  end
end
