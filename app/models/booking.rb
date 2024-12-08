class Booking < ApplicationRecord
  ### ASSOCIATIONS ###
  belongs_to :student, foreign_key: 'student_id', class_name: 'User'
  belongs_to :coach, foreign_key: 'coach_id', class_name: 'User'
  has_one :availability_slot

  ### VALIDATIONS ###
  validates :satisfaction_score, inclusion: { in: 1..5 }, allow_nil: true
  validates :status, presence: true

  ### ENUMS ### - can hook this up to a state machine like aasm if need be.
  enum :status, {
    booked: 0,
    started: 1,
    completed: 2,
    canceled: 3,
    rescheduled: 4
  }

  scope :for_student, ->(student_id) { where(student_id: student_id) }
  scope :for_coach, ->(coach_id) { where(coach_id: coach_id) }

  scope :upcoming, -> { where('start_time > ?', Time.current) }
  scope :past, -> { where('end_time < ?', Time.current) }
  scope :ongoing, -> { where('start_time <= ? AND end_time >= ?', Time.current, Time.current) }

  scope :missed, -> { past.booked }
  scope :upcoming_booked, -> { upcoming.booked }
  scope :past_completed, -> { past.completed }
end
