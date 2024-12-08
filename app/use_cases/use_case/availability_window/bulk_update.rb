# TODO: Revist slot generation. Parallelize with threads, place in sidekiq background job,
# or mix-in with cache. Consider linking with ice-cube gem for ical rrule format,
# where the availability_window holds the rules to generate the windows. The +1 month into the
# future is random, and would be nice to performanly/dynamically compute more on query level (create a view?).

# TODO: Revisit AvailabilityWindow.intervals jsonb - consider flattening to just start_time,
# end_time, or using something like tsrange with a db level overlap exclusion. Looping over
# the jsonb, the risk of key mismatch, and complexity of overlap validation logic is not worth it.
# I origionally chose jsonb becuase I though it would play nicely with upsert, but the
# above drawbacks is making me rethink.

# TODO: Add dry.rb or other validator into all service object & use cases. Consider monads.

module UseCase
  module AvailabilityWindow
    class BulkUpdate
      def initialize(coach:, availability:, timezone:)
        @coach = coach # TODO: is a coach validation
        @availability = availability
        @timezone = timezone
      end

      def call
        validate_inputs!

        ActiveRecord::Base.transaction do
          delete_stale_windows
          upsert_intervals
          precompute_and_upsert_slots
        end

        # Todo: Place any string going through API into yaml file,
        # prepare to use i18n
        UseCase::Result.success(data: { availability: availability })
      rescue ValidationError => e
        UseCase::Result.failure(errors: ["Validation failed: #{e.message}"])
      rescue ActiveRecord::Rollback
        UseCase::Result.failure(errors: ["Transaction rollback occurred"])
      rescue ActiveRecord::RecordInvalid => e
        UseCase::Result.failure(errors: ["Database error: #{e.message}"])
      rescue StandardError => e
        UseCase::Result.failure(errors: ["Unexpected error: #{e.message}"])
      end

      private

      attr_reader :coach, :availability, :timezone, :upserted_windows

      def validate_inputs!
        # TODO: validate intervals.
        raise ValidationError, "Coach must be present" unless coach.present?
        raise ValidationError, "Availability data must be an array" unless availability.is_a?(Array)
      end

      def delete_stale_windows
        return if stale_window_ids.empty?

        # TODO: Large edge case. Assume we want to preserve the og bookings
        # but in future need to think about conflict resolution when updating
        # recurring slots & pre-existing bookings. Have option to keep all,
        # cancel all, or reshcedule request to fit new schedule. May want to
        # decouple the concept of an availability window & the slots within them,
        # and give the student the more flexibility to create a booking within the
        # given range. 
        ::AvailabilitySlot.where(availability_window_id: stale_window_ids).delete_all
        ::AvailabilityWindow.where(id: stale_window_ids).delete_all
      end

      def stale_window_ids
        @stale_window_ids ||= ::AvailabilityWindow
          .where(coach_id: coach.id)
          .where.not(id: incoming_window_ids)
          .pluck(:id)
      end

      def incoming_window_ids
        @incoming_window_ids ||= availability.map { |entry| entry[:id] }.compact
      end

      def upsert_intervals
        @upserted_windows ||= ::AvailabilityWindow.upsert_all(
          formatted_availability_data,
          unique_by: :idx_on_coach_id_day_of_week,
          returning: %i[id coach_id day_of_week intervals]
        )
      end

      def formatted_availability_data
        @formatted_availability_data ||= availability.as_json.map do |entry|
          entry
            .except("id")
            .merge("coach_id" => coach.id)
        end
      end

      def precompute_and_upsert_slots
        availability_windows = ::Adapter::UpsertResponse
          .new(upserted_windows)
          .to_availability_windows

        slots = availability_windows.flat_map do |window|
          ::Service::SlotGenerator.new(
            window: window,
            timezone: timezone
          ).generate_slots
        end

        ::AvailabilitySlot.upsert_all(slots, unique_by: %i[coach_id start_time])
      end

      class ValidationError < StandardError; end
    end
  end
end
