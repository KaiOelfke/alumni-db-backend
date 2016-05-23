class Events::Event < ActiveRecord::Base
  has_many :fees, inverse_of: :event
  has_many :participations, inverse_of: :event

  scope :published, -> { where({delete_flag: false, published: true}) }

  enum etype: [ :without_application, :with_application ]

	validates :name, :etype, presence: true

	validates :published, :delete_flag, inclusion: { in: [true, false] }

	validates :description, :location, :slogan, :dates, :agenda,
            :contact_email, :phone_number, length: { minimum: 0 }, allow_nil: true

  validate :valid_facebook_url

  mount_uploader :logo_photo, EventLogoUploader

  mount_uploader :cover_photo, EventCoverUploader

  def valid_facebook_url
    if (facebook_url.to_s != '')
      errors.add(:facebook_url, 'is not valid') unless valid_url? facebook_url
    end
  end

  def valid_url?(url)
    uri = URI.parse(url)
    uri.kind_of?(URI::HTTP)
  rescue URI::InvalidURIError
    false
  end

=begin
  t.string :name, null: false
  t.text :description, default: ""
  t.string :location, default: ""
  t.string :dates, default: ""
  t.string :facebook_url
  t.boolean :published, null: false, default: false
  t.string :agenda
  t.string :contact_email
  t.boolean  :delete_flag, null: false, default: false
=end

end
