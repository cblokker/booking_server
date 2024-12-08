class CreateAvailabilityWindows < ActiveRecord::Migration[8.0]
  def change
    create_table :availability_windows do |t|
      t.jsonb :intervals, default: [] # NOTE: In retrospect, not the best approach to store ranges, esp when wanting to check overlap. 
      
      t.integer :day_of_week, null: false
      t.references :coach, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end 

    add_index :availability_windows, :intervals, using: :gin
    add_index :availability_windows, [:coach_id, :day_of_week], unique: true,
      name: 'idx_on_coach_id_day_of_week'
  end
end

# NOTE: Could do the following for start_time, end_time
# CREATE TABLE intervals (
#     id SERIAL PRIMARY KEY,
#     start_time TIMESTAMP NOT NULL,
#     end_time TIMESTAMP NOT NULL,
#     CONSTRAINT no_overlap EXCLUDE USING GIST (
#         tstzrange(start_time, end_time) WITH &&
#     )
# );
