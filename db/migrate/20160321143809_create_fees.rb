class CreateFees < ActiveRecord::Migration
  def change
    create_table :fees do |t|
      t.string :name, null: false
      t.integer :price, null: false
      t.date :deadline, null: false 
      t.belongs_to :event, index: true, foreign_key: true
      t.boolean  :delete_flag, :null => false, :default => false

      t.timestamps null: false
    end
  end
end
