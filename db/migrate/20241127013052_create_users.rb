class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.integer :role, null: false, default: 0
      t.string :phone_number, null: false
      t.string :image_url
      t.string :title

      t.timestamps
    end
  end
end




# TODO: Create RecurrenceRuleConverter (custom recurrence_rule -> to ical format converter)