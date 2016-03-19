class Subscriptions::Discount < ActiveRecord::Base
	belongs_to  :plan
	has_many :subscriptions
	has_many :subscriptions, through: :plan

	validates :plan, presence: true
	validates :name, presence: true
	validates :price, presence: true
	validates :code, presence: true
	validates :code, uniqueness: true

end
