class CreateBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :bookings do |t|
      t.datetime :start_time, null: false
      t.integer :status, null: false, default: 0
      t.integer :satisfaction_score
      t.text :notes

      t.references :availability_window, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: { to_table: :users }
      t.references :coach, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
