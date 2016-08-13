class Events::Fee < ActiveRecord::Base

  has_many :participations, inverse_of: :fee
  has_many :fee_codes, inverse_of: :fee

  belongs_to :event

	validates :event, :name, :price, :deadline, presence: true
  validates :name, length: {minimum: 3}
	validates :delete_flag, :public_fee, inclusion: { in: [true, false] }
  validates :price, numericality: true
  validate :check_deadline

  def check_deadline
    if (!deadline.is_a? Date)
      errors.add(:deadline, "is not valid")
    end
  end

end
