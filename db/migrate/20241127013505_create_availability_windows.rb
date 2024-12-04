class CreateAvailabilityWindows < ActiveRecord::Migration[8.0]
  def change
    create_table :availability_windows do |t|
      # t.time :start_time, null: false
      # t.time :end_time, null: false

      t.jsonb :intervals, default: []
      
      t.integer :day_of_week, null: false
      t.references :coach, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end 

    add_index :availability_windows, :intervals, using: :gin
    # add_index :availability_windows,
    #   [:coach_id, :day_of_week, :start_time, :end_time],
    #   unique: true, name: 'idx_on_coach_id_day_of_week_and_time'

      add_index :availability_windows,
      [:coach_id, :day_of_week, :intervals],
      unique: true, name: 'idx_on_coach_id_day_of_week_and_time'
  end
end
