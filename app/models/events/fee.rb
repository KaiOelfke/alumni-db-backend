class Events::Fee < ActiveRecord::Base

  has_many :participations, inverse_of: :fee
  has_many :fee_codes, inverse_of: :fee

  belongs_to :event

	validates :event, :name, :price, :deadline, :early_bird_fee, :honoris_fee, presence: true
  validates :name, length: {minimum: 3}
	validates :delete_flag, :early_bird_fee, :honoris_fee, inclusion: { in: [true, false] }
  validates :price, numericality: true
  validate :check_deadline

=begin
  t.string :name, null: false
  t.integer :price, null: false
  t.date :deadline, null: false 
  t.belongs_to :event, index: true
  t.boolean  :delete_flag, :null => false, :default => false
  t.timestamps null: false
=end

  def check_deadline
    if (!deadline.is_a? Date)
      errors.add(:date_of_birth, "is not valid")
    end
  end

end
