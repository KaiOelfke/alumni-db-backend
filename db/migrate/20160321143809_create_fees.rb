class CreateFees < ActiveRecord::Migration
  def change
    create_table :fees do |t|
      t.string :name, null: false
      t.integer :price, null: false
      t.date :deadline, null: false 
      t.boolean :public_fee, :null => false, :default => false

      t.belongs_to :event, index: true
      t.boolean  :delete_flag, :null => false, :default => false

      t.timestamps null: false
    end

    add_foreign_key :fees, :events, on_delete: :cascade

  end
end
