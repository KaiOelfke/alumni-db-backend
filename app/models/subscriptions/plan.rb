class Subscriptions::Plan < ActiveRecord::Base
	has_many :subscriptions 
	has_many :discounts
	validates :name, presence: true
	validates :price, presence: true
end
