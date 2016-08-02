require 'date'
require 'uri'
class User < ActiveRecord::Base
  include PgSearch
  include DeviseTokenAuth::Concerns::User

  

  pg_search_scope :search, :against => [
    :first_name,
    :last_name,
    :country,
    :city,
    :institution,
    :country_of_participation,
    :student_company_name,
    :university_name,
    :current_company_name,
    :current_job_position,
    :alumni_position,
    :short_bio
  ], :using => {
    tsearch: {
      dictionary: "simple",
      prefix: true,
      tsvector_column: "tsv"
    }
  }

  scope :completed_profile, -> { where(completed_profile: true) }

  belongs_to :subscription, :class_name => "Subscriptions::Subscription", foreign_key: "subscription_id", dependent: :destroy

  has_many :participations, :class_name => "Events::Participation", inverse_of: :user

  mount_uploader :avatar, AvatarUploader


  before_create :skip_confirmation!, :if => :isTestEnv?

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
  validate :reasonable_year_of_participation,  on: :update, if: :profile_completed?

  validate :reasonable_date_of_birth, on: :update, if: :profile_completed?
  validate :reasonable_country_of_participation,  on: :update, if: :profile_completed?

  validate :valid_urls

  validates :skype_id,
            :mobile_phone,
            :university_name,
            :university_major,
            :founded_company_name,
            :current_company_name,
            :current_job_position,
            :alumni_position,
            on: :update,
            allow_blank: true,
            allow_nil: true,
            length: {maximum: 1000}

  validates :short_bio,
            on: :update,
            allow_blank: true,
            allow_nil: true,
            length: {maximum: 160}

  # will_paginate
  self.per_page = 10

  #validate :reasonable_member
  def reasonable_member
    if (!member_since.is_a? Date) ||  member_since < Date.parse('01.01.1900') || member_since.year > Date.today.year

    end
  end

  def reasonable_year_of_participation
    if (!year_of_participation.is_a? Integer) ||  year_of_participation < 1900 || year_of_participation > Date.today.year
      errors.add(:year_of_participation, "is not valid")
    end
  end

  def reasonable_date_of_birth
    if (!date_of_birth.is_a? Date) ||  date_of_birth < Date.parse('01.01.1900') || date_of_birth.year > Date.today.year
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

  def valid_urls
    if (facebook_url.to_s != '')
      errors.add(:facebook_url, 'is not valid') unless valid_url? facebook_url
    end
    if (twitter_url.to_s != '')
      errors.add(:twitter_url, 'is not valid') unless valid_url? twitter_url
    end
    if (linkedin_url.to_s != '')
      errors.add(:linkedin_url, 'is not valid') unless valid_url? linkedin_url
    end
  end

  def valid_url?(url)
    uri = URI.parse(url)
    uri.kind_of?(URI::HTTP)
  rescue URI::InvalidURIError
    false
  end

  def token_validation_response
    self.as_json(
      except: [
      :tokens, :created_at, :updated_at, :customer_id, :subscription_id, :tsv
    ])
  end

  def as_json(options = {})
    super(options.reverse_merge( except: [:tsv],:methods => [:is_premium]))
    
  end

  def is_premium
    !!self.subscription_id
  end

  def isTestEnv?
    Rails.env.test?
  end

end
