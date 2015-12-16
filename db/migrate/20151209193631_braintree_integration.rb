class BraintreeIntegration < ActiveRecord::Migration
  def change
    create_table(:plans) do |t|
      t.string :braintree_plan_id, :null => false
      t.string :name, :null => false
      t.integer :price, :null => false
      t.boolean :default, :null => false
      t.string :description, :null => false, :default => ""
      t.boolean  :delete_flag, :null => false, :default => false
      t.datetime :expiry_at
    end

    create_table(:discounts) do |t|
      t.string :braintree_discount_id, :null => false     
      t.string :name, :null => false
      t.string :code, :null => false
      t.integer :price, :null => false
      t.string :description, :null => false, :default => ""
      t.boolean  :delete_flag, :null => false, :default => false
      t.datetime :expiry_at
      t.belongs_to :plan, index: true
    end

    create_table(:subscriptions) do |t|
      t.string :braintree_new_subscription_id, :null => false
      t.string :braintree_old_subscription_id, :null => false
      t.datetime :created_at, :null => false
      t.datetime :cancelled_at
      t.belongs_to :user, index: true
      t.belongs_to :plan, index: true
      t.belongs_to :discount, index: true   
    end
    
    add_column :users, :subscription_id, :string
  end
end
