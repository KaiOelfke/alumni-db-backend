class CreateParticipations < ActiveRecord::Migration
  def change
    create_table :participations do |t|
      t.belongs_to :fee, index: true
      t.belongs_to :user, index: true
      t.belongs_to :event, index: true
      t.belongs_to :fee_code, index: true

      t.timestamps null: false
      t.string   :braintree_transaction_id
      
      t.boolean :delete_flag, default: false 

      # particiption form
      t.text     :arrival
      t.text     :departure
      t.integer  :diet
      t.text     :allergies
      t.text     :extra_nights
      t.text     :other

    end

    add_foreign_key :participations, :fees,  on_delete: :cascade
    add_foreign_key :participations, :users, on_delete: :cascade
    add_foreign_key :participations, :events, on_delete: :cascade
    add_foreign_key :participations, :fee_codes, on_delete: :cascade

  end
end
