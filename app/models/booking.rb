class Booking < ApplicationRecord
  ### ASSOCIATIONS ###
  belongs_to :student, foreign_key: 'student_id', class_name: 'User'
  belongs_to :coach, foreign_key: 'coach_id', class_name: 'User'
  belongs_to :availability_slot

  ### VALIDATIONS ###
  validates :satisfaction_score, inclusion: { in: 1..5 }, allow_nil: true
  validates :status, presence: true

  ### ENUMS ###
  enum :status, {
    available: 0,
    booked: 1,
    completed: 2,
    canceled: 3,
    no_show: 4
  }

  ### INSTANCE METHODS ###
  def end_time
    start_time + duration.minutes
  end
end



# "Apply changes to future weeks" or "This week only."


  # validate :valid_booking_duration
  # validate :within_availability

  # def valid_booking_duration
  #   if (end_time - start_time) / 60 != booking_type.duration_minutes
  #     errors.add(:base, "Booking duration must match the selected booking type")
  #   end
  # end

  # def within_availability
  #   window = availability_window
  #   unless (start_time >= window.start_time && end_time <= window.end_time)
  #     errors.add(:base, 'Booking must fall within the availability window')
  #   end
  # end

  ### SCOPES ###
  # scope upcoming
  # scope past
  # scope current
  # scope past.pending == "no_show"