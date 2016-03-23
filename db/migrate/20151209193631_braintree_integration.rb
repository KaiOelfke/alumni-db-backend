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
      t.belongs_to :plan, index: true
    end

    create_table(:subscriptions) do |t|
      t.string :braintree_transaction_id
      t.datetime :created_at, :null => false
      t.belongs_to :plan, index: true
      t.belongs_to :discount, index: true
    end

    add_foreign_key :subscriptions, :plans, on_delete: :restrict
    add_foreign_key :subscriptions, :discounts, on_delete: :restrict
    add_foreign_key :discounts, :plans, on_delete: :restrict


    add_column :users, :subscription_id, :integer, index: true
    add_foreign_key :users, :subscriptions, on_delete: :nullify

  end
end
