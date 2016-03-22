class Event < ActiveRecord::Base
  has_many :fees
  scope :published, -> { where(published: true) }

end
