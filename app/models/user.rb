class User < ActiveRecord::Base
  include DeviseTokenAuth::Concerns::User
  before_create :skip_confirmation!

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
            presence: true, on: :update

  # male = 0, female = 1
  validates :gender, inclusion: { in: [0, 1], message: "%(value) is not valid."}, on: :update
  # company = 0, startup = 1, other = 2
  validates :program_type, inclusion: { in: [0, 1, 2], message: "%(value) is not valid."}, on: :update

  validates :year_of_participation, numericality: {only_integer: true}, on: :update
  validate :reasonable_year_of_participation, on: :update

  validate :reasonable_date_of_birth, on: :update
  validate :reasonable_country_of_participation, on: :update


  def reasonable_year_of_participation
    if !year_of_participation.is_a? Integer ||  year_of_participation < 1900 || year_of_participation > Date.today.year
      errors.add(:year_of_participation, "is not valid")
    end
  end

  def reasonable_date_of_birth
    if !date_of_birth.is_a? Date ||  date_of_birth < Date.parse('01.01.1900') || date_of_birth > Date.today.year
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
    true
  end

end
