class BookingType < ApplicationRecord
  # Associations
  belongs_to :coach, class_name: 'User'
  # has_many :availability_windows, dependent: :destroy
  has_many :bookings, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :duration_minutes, presence: true, numericality: { only_integer: true, greater_than: 0 }

  # Scopes (optional, for convenience)
  scope :for_coach, ->(coach_id) { where(coach_id: coach_id) }
end