class User < ApplicationRecord
  # TODO: Add JWT to replace session store
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  ### ASSOCIATIONS ###
  has_many :availability_windows, foreign_key: :coach_id, dependent: :destroy
  has_many :availability_slots, foreign_key: :coach_id
  has_many :student_bookings, foreign_key: :student_id, class_name: 'Booking'
  has_many :coach_bookings, foreign_key: :coach_id, class_name: 'Booking'

  ### VALIDATIONS ###
  validates :first_name, :last_name, :phone_number, presence: true
  validates :role, inclusion: { in: %w[student coach] }
  # TODO: Add phone number validator + getter/setter to strip/add phone string format

  ### ENUMS ###
  enum :role, { student: 0, coach: 1 }

  ### SCOPES ###
  scope :students, -> { where(role: :student) }
  scope :coaches, -> { where(role: :coach) }

  # NOTE: Can extract this out to own table if we want a coach to be able to
  # create 
  DEFAULT_BOOKING_TYPE = {
    name: '2-hour session',
    duration_minutes: 120
  }
end
