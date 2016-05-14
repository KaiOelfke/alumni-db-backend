class CreateParticipations < ActiveRecord::Migration
  def change
    create_table :participations do |t|
      t.belongs_to :fee, index: true
      t.belongs_to :user, index: true
      t.belongs_to :event, index: true
      
    	t.timestamps null: false
    	t.string   :braintree_transaction_id
    	
    	# in review 1 / approved 2 / paid 3
    	t.integer  :status, default: 0
    	t.boolean :delete_flag, default: false 

      # particiption form
      t.datetime :arrival
      t.datetime :departure
      t.integer  :diet
      t.text   	 :allergies
      t.text     :extra_nights
      t.text 		 :other

    	# application form only if the event type is 2
    	t.text		 :motivation
    	t.string   :cv_file 

    end

    add_foreign_key :participations, :fees,  on_delete: :cascade
    add_foreign_key :participations, :users, on_delete: :cascade
    add_foreign_key :participations, :events, on_delete: :cascade

  end
end
