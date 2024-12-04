module Api
  module V1
    class BookingTypesController < ApplicationController
      def index
        booking_types = BookingType.where(coach_id: params[:coach_id])

        render json: booking_types
      end
    end
  end
end
