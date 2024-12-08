module Api
  module V1
    class AvailabilityWindowsController < ApplicationController 
      def index
        availability = current_user.availability_windows.order(:day_of_week)
        render json: availability
      end

      def bulk_update
        result = UseCase::AvailabilityWindow::BulkUpdate.new(
          coach: current_user,
          availability: availability_params[:availability_windows],
          timezone: availability_params[:timezone]
        ).call

        if result.success?
          render json: result.data
        else
          render json: result.errors
        end
      end
    
      private
    
      def availability_params
        params.permit(:timezone, availability_windows: [
          :id,
          :day_of_week,
          intervals: [
            :start_time,
            :end_time
          ]
        ])
      end
    end
  end
end
