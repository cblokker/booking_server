# class GenerateBookingTypeSlots
#   require 'ice_cube'

#   def initialize(coach:, booking_type:, date_range:)
#     @coach = coach
#     @booking_type = booking_type
#     @date_range = date_range
#   end

#   def call
#     availability_windows = coach.availability_windows.where(booking_type: [@booking_type, nil])
#     availability_windows.flat_map { |window| generate_slots_for_window(window) }
#   end

#   private

#   attr_reader :coach, :booking_type, :date_range

#   def generate_slots_for_window(window)
#     schedule = IceCube::Schedule.new(window.start_time)
#     schedule.add_recurrence_rule(IceCube::Rule.daily.until(window.end_time))

#     schedule.occurrences_between(@date_range.begin, @date_range.end).map do |occurrence|
#       {
#         start_time: occurrence,
#         end_time: occurrence + @booking_type.duration_minutes.minutes
#       }
#     end
#   end
# end
