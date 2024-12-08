module Adapter
  class UpsertResponse
    def initialize(upsert_response)
      @upsert_response = upsert_response
    end

    def to_availability_windows
      upsert_response.rows.map do |row|
        {
          id: row[0],
          coach_id: row[1],
          day_of_week: row[2],
          intervals: parse_intervals(row[3])
        }
      end
    end

    private

    attr_reader :upsert_response

    def parse_intervals(intervals_json)
      JSON.parse(intervals_json)
    rescue JSON::ParserError
      []
    end
  end
end
