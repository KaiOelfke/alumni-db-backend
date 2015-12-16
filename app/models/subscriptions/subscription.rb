class Subscriptions::Subscription < ActiveRecord::Base
	belongs_to :user
	belongs_to :plan
	belongs_to :discount
end
