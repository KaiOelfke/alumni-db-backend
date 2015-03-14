require 'date'
class User < ActiveRecord::Base
  include DeviseTokenAuth::Concerns::User
  mount_uploader :avatar, AvatarUploader

  #before_create :skip_confirmation!

  validates :first_name,
            :last_name,
            :country,
            :city,
            :date_of_birth,
            :gender,
            :program_type,
            :institution,
            :year_of_participation,
            :country_of_participation,
            :student_company_name,
            presence: true, on: :update, if: :profile_completed?

  # male = 0, female = 1
  validates :gender, inclusion: { in: [0, 1], message: "%(value) is not valid."}, on: :update, if: :profile_completed?
  # company = 0, startup = 1, other = 2
  validates :program_type, inclusion: { in: [0, 1, 2], message: "%(value) is not valid."}, on: :update, if: :profile_completed?

  validates :year_of_participation, numericality: {only_integer: true}, on: :update, if: :profile_completed?
  validate :reasonable_year_of_participation , on: :update, if: :profile_completed?

  validate :reasonable_date_of_birth, on: :update, if: :profile_completed?
  validate :reasonable_country_of_participation, on: :update, if: :profile_completed?



  def reasonable_year_of_participation
    if !year_of_participation.is_a? Integer ||  year_of_participation < 1900 || year_of_participation > Date.today.year
      errors.add(:year_of_participation, "is not valid")
    end
  end

  def reasonable_date_of_birth
    if !date_of_birth.is_a? Date ||  date_of_birth < Date.parse('01.01.1900') || date_of_birth.year > Date.today.year
      errors.add(:date_of_birth, "is not valid")
    end
  end

  def reasonable_country_of_participation
    unless country_of_participation.in?(Rails.configuration.member_countries)
      errors.add(:country_of_participation, "is not valid")
    end
  end

# Overwrite devise token auth email validation settings
# to validate email adresses
  def email_required?
    true
  end

  def email_changed?
    attribute_changed?(:email)
  end

  def after_confirmation
    self.confirmed_email = true
    self.save
  end

  def profile_completed?
    self.completed_profile
  end

end
