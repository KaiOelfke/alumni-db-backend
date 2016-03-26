class Events::Fee < ActiveRecord::Base
  belongs_to :event

	validates :event, :name, :price, :deadline, presence: true
	validates :delete_flag, inclusion: { in: [true, false] }
  validates :price, numericality: true
  validates :name, length: { minimum: 1 }
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
