# // Example Response from GET /availability_windows
# [
#   {
#     "day": "MON",
#     "slots": [
#       { "start": "09:00", "end": "17:00" },
#       { "start": "18:00", "end": "19:00" }
#     ]
#   },
#   {
#     "day": "TUE",
#     "slots": [
#       { "start": "09:00", "end": "13:00" },
#       { "start": "14:00", "end": "17:00" }
#     ]
#   }
# ]



module UseCase
  module AvailabilityWindow
    class Create
      # A coach creates availability windows, which then translates to pre-computed slots
      # depending on the chosen booking_type_id
      def initialize(coach_id:, booking_type_id:, start_time:, end_time:, recurrence_rule: :days)
        @coach_id = coach_id
        @booking_type_id = booking_type_id
        @start_time = start_time
        @end_time = end_time
        @recurrence_rule = recurrence_rule
      end

      def call
        availability_window = AvailabilityWindow.new(params)
        set_default_recurrence_rule(availability_window)
        # generate the slots
        # notification

        if availability_window.save
          Result.success(availability_window)
        else
          Result.failure(availability_window.errors.full_messages)
        end
      end

      private

      attr_reader :coach_id, :booking_type_id, :start_time, :end_time, :recurrence_rule

      # this to be converted to ical
      def set_default_recurrence_rule(availability_window)
        availability_window.recurrence_rule ||= {}
        availability_window.recurrence_rule = {
          "type" => "weekly",
          "interval" => 1,
          "end_date" => nil
        }.merge(availability_window.recurrence_rule)
      end
    end
  end
end
