module Api
  module V1
    class AvailabilityWindowsController < ApplicationController
      before_action :set_coach

      # GET /coaches/:coach_id/availability_windows
      def index
        availability = @coach.availability_windows.order(:day_of_week)

        render json: availability
      end

      # PUT /coaches/:coach_id/availability_windows/bulk_update
      def bulk_update
        result = UseCase::AvailabilityWindow::BulkUpdate.new(
          coach: @coach,
          availability: availability_params
        ).call

        if result.success?
          render json: result.data
        else
          render json: result.errors
        end
      end
    
      private
    
      def set_coach
        @coach = User.find(params[:coach_id])
      rescue ActiveRecord::RecordNotFound
        render json: { success: false, error: "Coach not found" }, status: :not_found
      end

      def availability_params
        params.require(:availability_windows).map do |availability_day|
          availability_day.permit(
            :id,
            :day_of_week,
            :coach_id,
            intervals: [
              :start_time,
              :end_time,
            ]
          )
        end
      end
    end
  end
end
