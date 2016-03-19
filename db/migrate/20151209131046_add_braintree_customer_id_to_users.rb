class AddBraintreeCustomerIdToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :customer_id, :string, :default => ''
  end
end
