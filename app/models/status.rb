class Status < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => 'users_statuses'

  enum kind: %w(registered email_confirmed profile_completed)
  scope :registered, -> { where(kind: kinds[:registered]) }
  scope :email_confirmed, -> { where(kind: kinds[:email_confirmed]) }
  scope :profile_completed, -> { where(kind: kinds[:profile_completed]) }

end
