module UseCase
  module AvailabilityWindow
    class BulkUpdate
      Result = Struct.new(:success?, :errors, :data)

      def initialize(coach:, availability:)
        @coach = coach
        @availability = availability
      end

      def call
        validate_inputs!
        process_availability_update

        Result.new(true, nil, @availability)
      rescue ValidationError => e
        Result.new(false, ["Validation failed: #{e.message}"], nil)
      rescue ActiveRecord::Rollback
        Result.new(false, ["Transaction rollback occurred"], nil)
      rescue ActiveRecord::RecordInvalid => e
        Result.new(false, ["Database error: #{e.message}"], nil)
      rescue StandardError => e
        Result.new(false, ["Unexpected error: #{e.message}"], nil)
      end

      private

      def validate_inputs!
        raise ValidationError, "Coach must be present" unless @coach.present?
        raise ValidationError, "Availability data must be an array" unless @availability.is_a?(Array)
      end

      def process_availability_update
        ActiveRecord::Base.transaction do
          delete_stale_windows
          upsert_intervals
          precompute_and_upsert_slots
        end
      end

      def delete_stale_windows
        existing_ids = ::AvailabilityWindow.where(coach_id: @coach.id).pluck(:id)
        incoming_ids = @availability.map { |entry| entry[:id] }.compact
        stale_ids = existing_ids - incoming_ids

        # Note - could rely on a dependent destroy through the association, but
        # 1) since upsert bypasses validations, wary of behavior
        # 2) More performant, as dependent destroy will single deletes queries per item
        if stale_ids.any?
          ::AvailabilitySlot.where(availability_window_id: stale_ids).delete_all
          ::AvailabilityWindow.where(id: stale_ids).delete_all
        end
      end

      def upsert_intervals
        ::AvailabilityWindow.upsert_all(
          formatted_availability_data,
          unique_by: :idx_on_coach_id_day_of_week_and_time
        )
      end

      def precompute_and_upsert_slots
        slots = generate_slots(@availability)
        binding.pry
        ::AvailabilitySlot.upsert_all(slots, unique_by: %i[coach_id start_time])
      end

      def formatted_availability_data
        @availability.as_json.map { |entry| entry.except("id") }
      end

      # consider moving generate_slots into custom class - can do time ranges, etc.
      # And call method in both postgres & redis updates.
      def generate_slots(availability_data)
        availability_data.flat_map do |availability|
          generate_slots_for_availability(availability)
        end
      end

      def generate_slots_for_availability(availability)
        availability[:intervals].flat_map do |interval|
          generate_slots_for_interval(interval, availability)
        end
      end

      def generate_slots_for_interval(interval, availability)
        start_time = interval[:start_time].to_time
        end_time = interval[:end_time].to_time
        default_duration = 2.hours

        [].tap do |slot_records|
          while start_time + default_duration <= end_time
            slot_records << build_slot(start_time, availability, default_duration)
            start_time += default_duration
          end
        end
      end

      def build_slot(start_time, availability, duration)
        {
          start_time: start_time,
          end_time: start_time + duration,
          coach_id: availability[:coach_id],
          availability_window_id: availability[:id],
          booked: false
        }
      end

      class ValidationError < StandardError; end
    end
  end
end
