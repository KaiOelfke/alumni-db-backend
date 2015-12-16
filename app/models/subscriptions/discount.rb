class Subscriptions::Discount < ActiveRecord::Base
	belongs_to  :plan
	has_many :subscriptions
	has_many :subscriptions, through: :plan
end
