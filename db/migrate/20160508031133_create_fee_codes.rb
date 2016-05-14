class CreateFeeCodes < ActiveRecord::Migration
  def change
    create_table :fee_codes do |t|
      t.string :code, null: false
      t.belongs_to :user, index: true
      t.belongs_to :fee, index: true

    	t.boolean :delete_flag, default: false 

    	t.timestamps null: false

    end

    add_index :fee_codes, :code, unique: true
    add_foreign_key :fee_codes, :fees,  on_delete: :cascade
    add_foreign_key :fee_codes, :users, on_delete: :cascade

  end
end
