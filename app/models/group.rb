class Group < ActiveRecord::Base
  has_many :memberships
  has_many :users, through: :memberships

  mount_uploader :picture, AvatarUploader
end
