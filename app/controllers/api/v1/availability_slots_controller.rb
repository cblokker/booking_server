module Api
  module V1
    class AvailabilitySlotsController < ApplicationController
      def index
        coach = User.find(params[:coach_id])
        date = params[:date].to_date
    
        # Fetch all slots for the given date and coach
        slots = AvailabilitySlot
                  .where(coach: coach)
                  .where("start_time >= ? AND start_time < ?", date.beginning_of_day, date.end_of_day)
                  .includes(:booking)
                  .order(:start_time)
    
        render json: slots.map { |slot| slot_json(slot) }
      end
    
      private
    
      def slot_json(slot)
        {
          id: slot.id,
          start_time: slot.start_time,
          end_time: slot.end_time,
          booked: slot.booked,
          booking_id: slot.booking_id
        }
      end
    end
  end
end
