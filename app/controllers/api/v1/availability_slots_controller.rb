module Api
  module V1
    class AvailabilitySlotsController < ApplicationController
      # TODO: Move to query object
      # - can introduce start_date, end_date, & pagination & use react query useInfiniteQuery
      def index
        coach = User.find(params[:coach_id])

        if params[:date]
          date = params[:date].to_date
          slots = AvailabilitySlot
                    .where(coach: coach)
                    .where("start_time >= ? AND start_time < ?", date.beginning_of_day, date.end_of_day)
                    .where(booked: false)
                    .order(:start_time)
        else
          slots = AvailabilitySlot
            .where(coach: coach)
            .where(booked: false)
            .order(:start_time)
        end
    
        render json: slots
      end
    end
  end
end
