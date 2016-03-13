class Subscriptions::Subscription < ActiveRecord::Base
	belongs_to :plan
	belongs_to :discount
  before_destroy :nullify_subscription_id

  validates :plan, presence: true

  private
    def nullify_subscription_id
    	@user = User.find_by(:subscription_id => id)
    	@user.subscription_id = nil
    	@user.save!
    end
end
