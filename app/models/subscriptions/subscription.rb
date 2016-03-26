class Subscriptions::Subscription < ActiveRecord::Base
	belongs_to :plan
	belongs_to :discount

  validates :plan, presence: true
  validates :discount, presence: true, allow_nil: true

end
