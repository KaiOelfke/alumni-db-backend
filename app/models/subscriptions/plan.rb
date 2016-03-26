class Subscriptions::Plan < ActiveRecord::Base
	has_many :subscriptions, inverse_of: :plan
	has_many :discounts, inverse_of: :plan

	validates :delete_flag, inclusion: { in: [true, false] }	
	validates :name, :price, presence: true
end
