class Events::FeeCode < ActiveRecord::Base

  belongs_to :fee
  belongs_to :user

	validates :code, :fee, :user, presence: true
  validates_uniqueness_of :code

 	before_create :generate_token

  private

  def generate_token
  	
    require 'active_support/core_ext/securerandom'

    self.code = loop do
    	
      random_token = SecureRandom.base58(24)
      short_code   = random_token[0..3] + '-' + random_token[4..7] + '-' + random_token[8..11]

      break short_code unless FeeCode.exists?(code: short_code)
    end
  end


end
