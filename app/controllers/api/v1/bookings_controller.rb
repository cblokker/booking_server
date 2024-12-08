module Api
  module V1
    class BookingsController < ApplicationController
      def index
        bookings = ::QueryObject::BookingFilter.new(
          current_user,
          booking_params[:state]
        ).filter.order(:start_time) # TODO: switch to start_date (b/c date object) 

        # TODO: Move to Serializer to standardize object payloads
        render json: bookings.as_json(include: { 
          student: { only: [:id, :first_name, :last_name, :phone_number] }, 
          coach: { only: [:id, :first_name, :last_name, :phone_number] }
        })
      end

      # Todo: current user check & app wide authorization through ... cancancan?
      def create
        result = ::UseCase::Booking::Create.new(
          student: current_user,
          availability_slot_id: params[:availability_slot_id]
        ).call
      
        if result.success?
          render json: result.data, status: :created
        else
          render json: result.error, status: :unprocessable_entity
        end
      end

      def complete
        booking = Booking.find(params[:booking_id])

        if booking.update(status: :completed, **complete_booking_params)
          render json: booking
        else
          render json: { errors: booking.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def booking_params
        params.permit(:state)
      end

      def complete_booking_params
        params.require(:booking).permit(:satisfaction_score, :notes)
      end
    end
  end
end
