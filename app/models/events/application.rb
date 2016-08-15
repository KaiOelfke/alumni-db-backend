class Events::Application < ActiveRecord::Base
  belongs_to :event
  belongs_to :user
  
  validate :check_event

  private

  def check_event
    event.with_application? or event.with_payment_application?
  end
end
