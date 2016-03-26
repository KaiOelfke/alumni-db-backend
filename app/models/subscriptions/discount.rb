class Subscriptions::Discount < ActiveRecord::Base
	belongs_to :plan
	has_many :subscriptions, inverse_of: :discount
	has_many :subscriptions, through: :plan, inverse_of: :discount

	validates :delete_flag, inclusion: { in: [true, false] }
	validates :plan, :name, :price, :code,   presence: true
	validates :code, uniqueness: true

end
