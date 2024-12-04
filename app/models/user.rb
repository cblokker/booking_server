class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  ### ASSOCIATIONS ###
  has_many :availability_windows, foreign_key: :coach_id, dependent: :destroy
  has_many :availability_slots, foreign_key: :coach_id
  has_many :student_bookings, foreign_key: :student_id, class_name: 'Booking'
  has_many :coach_bookings, foreign_key: :coach_id, class_name: 'Booking'

  ### VALIDATIONS ###
  validates :first_name, :last_name, :phone_number, presence: true
  validates :role, inclusion: { in: %w[student coach] }
  # TODO: Add phone number string sanitizer & validator

  ### ENUMS ###
  enum :role, { student: 0, coach: 1 }

  ### SCOPES ###
  scope :students, -> { where(role: :student) }
  scope :coaches, -> { where(role: :coach) }

  DEFAULT_BOOKING_TYPE = {
    name: '2-hour session',
    duration_minutes: 120
  }
end
