module UseCase
  module Booking
    class Create
      def initialize(student:, availability_slot_id:)
        @student = student
        @availability_slot_id = availability_slot_id
      end

      def call
        return Result.failure(error: "Slot is already booked") if slot.booked?

        ActiveRecord::Base.transaction do
          create_booking
          mark_slot_as_booked
        end

        UseCase::Result.success(data: { booking_id: booking.id, slot_id: slot.id })
      rescue ActiveRecord::RecordInvalid => e
        UseCase::Result.failure(errors: "Failed to book slot: #{e.message}")
      rescue StandardError => e
        UseCase::Result.failure(errors: "Unexpected error: #{e.message}")
      end

      private

      attr_reader :student, :availability_slot_id, :booking

      def slot
        @slot ||= ::AvailabilitySlot.find(availability_slot_id)
      end

      def create_booking
        @booking ||= ::Booking.create!(
          student_id: student.id,
          coach_id: slot.coach_id,
          start_time: slot.start_time,
          end_time: slot.end_time
        )
      end

      def mark_slot_as_booked
        slot.update!(booked: true, booking_id: booking.id)
      end
    end
  end
end
