class Events::Participation < ActiveRecord::Base
  belongs_to :user, :class_name => "User"
  belongs_to :fee
  belongs_to :event
  belongs_to :fee_code
  
  validates :user, :event, :arrival, :departure, :diet, presence: true
  validate :check_event
  validate :check_braintree, :unless => :validating_before_payment?
  validates_uniqueness_of :user, :scope => [:event]

  attr_accessor :validating_before_payment

  def validating_before_payment?
    @validating_before_payment
  end

  def check_braintree
    return unless errors.blank?
    if self.event.with_payment? or self.event.with_payment_application?
      errors.add(:braintree_transaction_id, 'payment not valid') unless self.braintree_transaction_id?
    end
  end

  def check_event
    return unless errors.blank?
    errors.add(:fee_code, 'event type does not require code') if self.event.without_application_payment? and self.fee_code_id
    errors.add(:fee, 'event type does not require fee') if (self.event.without_application_payment? or self.event.with_application?) and self.fee_id
    errors.add(:fee, 'event type requires fee') if (self.event.with_payment? or self.event.with_payment_application?) and !self.fee_id
    errors.add(:fee_code, 'event type requires code') if (self.event.with_application? or self.event.with_payment_application?) and !self.fee_code_id
  end
end
