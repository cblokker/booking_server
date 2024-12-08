class AvailabilityWindow < ApplicationRecord
  ### ASSOCIATIONS ###
  has_many :availability_slots, dependent: :destroy

  ### VALIDATIONS ###
  validates :intervals, :day_of_week, presence: true

  # TODO: validate :no_overlapping_intervals. Note that this is critical to the app
  # See note in UseCase::AvailabilityWindows::BulkUpdate about overlap complexity with the
  # self.intervals as a jsonb. Next step would be to migrate to start_time, end_time, or 
  # use a range type see custom range type https://www.postgresql.org/docs/current/rangetypes.html#RANGETYPES-DEFINING

  enum :day_of_week, {
    sunday: 0,
    monday: 1,
    tuesday: 2,
    wednesday: 3,
    thursday: 4,
    friday: 5,
    saturday: 6
  }
end
