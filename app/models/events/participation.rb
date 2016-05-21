class Events::Participation < ActiveRecord::Base
  belongs_to :user, :class_name => "User"
  belongs_to :fee
  belongs_to :event

  enum status: [ :submitted, :in_review, :approved, :paid ]


  validates :user, :fee, presence: true

  validates :cv_file, :motivation,  presence: true, if: "in_review?"

  validates :arrival, :departure, :braintree_transaction_id, :diet,  presence: true, if: "paid?"

=begin

  t.user 
  t.fee

	# particiption form
	t.datetime :arrival
	t.datetime :departure
	t.integer  :diet
	t.text   	 :allergies
	t.text     :extra_nights
	t.text 		 :other

	# application form only if the event type is 2
	t.text		 :motivation
	t.string   :cv_file 

=end

end
