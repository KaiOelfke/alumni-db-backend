class Events::Participation < ActiveRecord::Base
  belongs_to :user, :class_name => "User"
  belongs_to :fee


  validates :user, :fee, presence: true

=begin

  

  t.user 
  t.fee
=end

end
