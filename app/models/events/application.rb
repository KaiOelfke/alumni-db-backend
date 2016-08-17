class Events::Application < ActiveRecord::Base
  belongs_to :event
  belongs_to :user
  
  validate :check_event
  validates :motivation, :user, :event, presence: true
  validates_uniqueness_of :user, :scope => [:event]

  mount_uploader :cv_file, CurriculumVitaeUploader
  

  private

  def check_event
    errors.add(:event, 'event type is without application') if event.without_application_payment? or event.with_payment?
  end
end
