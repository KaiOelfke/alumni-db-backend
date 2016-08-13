class CreateEventApplications < ActiveRecord::Migration
  def change
    create_table :applications do |t|
      t.text :motivation
      t.string :cv_file
      t.belongs_to :event, index: true
      t.belongs_to :user, index: true

      t.timestamps null: false
    end
    add_foreign_key :applications, :events, on_delete: :cascade
    add_foreign_key :applications, :users, on_delete: :cascade
  end
end
