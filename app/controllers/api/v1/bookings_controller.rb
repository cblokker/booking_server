module Api
  module V1
    class BookingsController < ApplicationController

      # create filter for booking, upcoming, completed, missed, canceled
      def index
        if params[:student_id]
          bookings = Booking.where(student_id: params[:student_id])
        elsif params[:coach_id]
          bookings = Booking.where(coach_id: params[:coach_id])
        else
          bookings = Booking.all
        end
        render json: bookings
      end

      def create
        slot = AvailabilitySlot.find(params[:availability_slot_id])
    
        if slot.booked
          render json: { error: "Slot is already booked" }, status: :unprocessable_entity
          return
        end
    
        ActiveRecord::Base.transaction do
          booking = Booking.create!(
            student_id: current_user.id,
            coach_id: slot.coach_id,
            availability_slot_id: slot.id,
            start_time: slot.start_time,
            end_time: slot.end_time
          )
          slot.update!(booked: true, booking_id: booking.id)
        end
    
        render json: { message: "Slot successfully booked" }, status: :created
      end

      # def create
      #   precomputed_slot = PrecomputedSlot.find(params[:precomputed_slot_id])

      #   if precomputed_slot.booked
      #     render json: { error: 'Slot already booked' }, status: :unprocessable_entity
      #     return
      #   end

      #   booking = Booking.new(
      #     precomputed_slot: precomputed_slot,
      #     student_id: params[:student_id],
      #     status: 'pending'
      #   )

      #   if booking.save
      #     precomputed_slot.update(booked: true)
      #     render json: booking, status: :created
      #   else
      #     render json: { errors: booking.errors.full_messages }, status: :unprocessable_entity
      #   end
      # end

      def update
        booking = Booking.find(params[:id])
        if booking.update(booking_params)
          render json: booking
        else
          render json: { errors: booking.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        booking = Booking.find(params[:id])
        precomputed_slot = booking.precomputed_slot
        booking.destroy
        precomputed_slot.update(booked: false)
        head :no_content
      end

      private

      def booking_params
        params.require(:booking).permit(:status)
      end
    end
  end
end
