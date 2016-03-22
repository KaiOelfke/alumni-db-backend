class BraintreeIntegration < ActiveRecord::Migration
  def change
    create_table(:plans) do |t|
      t.string :name, :null => false
      t.integer :price, :null => false
      t.boolean :default, :null => false
      t.string  :description, :null => false, :default => ""
      t.boolean  :delete_flag, :null => false, :default => false
    end

    create_table(:discounts) do |t|
      t.string :name, :null => false
      t.string :code, :null => false
      t.integer :price, :null => false
      t.string :description, :null => false, :default => ""
      t.boolean  :delete_flag, :null => false, :default => false
      t.datetime :expiry_at
      t.belongs_to :plan, index: true, foreign_key: true
    end

    create_table(:subscriptions) do |t|
      t.string :braintree_transaction_id
      t.datetime :created_at, :null => false
      t.belongs_to :plan, index: true, foreign_key: true
      t.belongs_to :discount, index: true, foreign_key: true   
    end

    add_column :users, :subscription_id, :integer, index: true
  end
end
