class ManageBookingService
  def initialize(coach_id:, booking_params:)
    @coach_id = coach_id
    @booking_params = booking_params
  end

  def create_booking
    ActiveRecord::Base.transaction do
      Booking.create!(@booking_params)

      AvailabilitySlotCacheService.new(@coach_id).update_cache # remove that from the availability
    end
  rescue StandardError => e
    Rails.logger.error("Failed to create booking: #{e.message}")
    raise
  end

  # aka complete_call
  def complete_booking
    # update state
    # notifications
    # 
  end

  # TODO
  def delete_booking(booking)
  end
end
