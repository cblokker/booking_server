class CreateAvailabilitySlots < ActiveRecord::Migration[8.0]
  def change
    create_table :availability_slots do |t|
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false # duration?
      t.bigint :coach_id, null: false
      t.bigint :availability_window_id, null: false
      t.boolean :booked, default: false, null: false
      t.bigint :booking_id

      t.timestamps
    end

    add_index :availability_slots, [:coach_id, :start_time], unique: true, name: "index_availability_slots_on_coach_and_start"
    add_index :availability_slots, :availability_window_id
    add_index :availability_slots, :booking_id

    add_foreign_key :availability_slots, :availability_windows, column: :availability_window_id
    add_foreign_key :availability_slots, :bookings, column: :booking_id
    add_foreign_key :availability_slots, :users, column: :coach_id
  end
end
