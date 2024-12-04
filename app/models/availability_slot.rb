class AvailabilitySlot < ApplicationRecord
  belongs_to :coach, class_name: "User"
  belongs_to :availability_window
  belongs_to :booking, optional: true

  validates :start_time, :end_time, presence: true
  validates :booked, inclusion: { in: [true, false] }
end
