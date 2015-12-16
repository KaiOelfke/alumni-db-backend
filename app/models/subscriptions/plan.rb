class Subscriptions::Plan < ActiveRecord::Base
	has_many :subscriptions
	has_many :discounts
end
