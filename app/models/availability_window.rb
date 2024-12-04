class AvailabilityWindow < ApplicationRecord
  ### ASSOCIATIONS ###
  has_many :availability_slots, dependent: :destroy

  ### VALIDATIONS ###
  validates :intervals, :day_of_week, presence: true
  # validate :no_overlapping_intervals
    # TODO: Add phone number validator + getter/setter to strip/add phone string format

  enum :day_of_week, {
    sunday: 0,
    monday: 1,
    tuesday: 2,
    wednesday: 3,
    thursday: 4,
    friday: 5,
    saturday: 6
  }

  private

  def recurrence_rule
    schedule = IceCube::Schedule.new
    schedule.add_recurrence_rule(IceCube::Rule.weeky.day(self.day_of_week))
  end

  # def no_overlapping_intervals
  #   overlapping = AvailabilityWindow
  #                   .where(coach_id: coach_id, day_of_week: day_of_week)
  #                   .where('intervals && tsrange(:start_time, :end_time)', start_time: start_time, end_time: end_time)
  #   if overlapping.exists?
  #     errors.add(:intervals, "overlaps with another availability interval")
  #   end
  # end
end




  # MOVE TO SERVICE OBJECT #
  # def generate_rigid_slots
  #   duration = booking_type.duration_minutes.minutes
  #   slots = []
  #   current_time = start_time

  #   while current_time + duration <= end_time
  #     slots << {
  #       start_time: current_time,
  #       end_time: current_time + duration
  #     }

  #     current_time += duration
  #   end

  #   slots
  # end

  # Add validation to check for no date overlap between availabilty windows on
  # a per coach level.

  # Let's not focus on recurring windows for right now.


# Decisions: I wanted to go for a full fledged calendar UI, but with time constraints
# (and simulating MVP + agile itterative approach), decided to go for simpler UI

# A coach can create weekly availabilities for a given "booking type", inspired by Calendly

# A student can create booking based on pre-computed availabiltiy slots.

# best way to translate pre-computed availabiltiy slot to a booking

# 
