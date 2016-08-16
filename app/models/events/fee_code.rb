class Events::FeeCode < ActiveRecord::Base

  belongs_to :fee
  belongs_to :user
  belongs_to :event

  before_validation :generate_token

	validates :code, :event, presence: true
  validates :used_flag, :delete_flag, inclusion: { in: [true, false] }
  validates_uniqueness_of :code
  validate :valid_fee_and_event
  validate :valid_user

  private

  #Depending on the event type, there has to be a fee, no fee, or a fee is optional.
  #If there is a fee it needs to have certain attributes.
  def valid_fee_and_event
    if self.event.without_application_payment?
      return false
    elsif self.event.with_payment?
      return (fee? and valid_fee)
    elsif self.event.with_payment_application?
      return (!fee? or valid_fee)
    elsif self.event.with_application?
      return !fee?
    end
  end

  #TODO: Why does self.fee? not work here
  def fee?
    !!self.fee
  end

  def valid_fee
    !self.fee.public_fee and self.fee.event.id.to_s == self.event.id.to_s
  end

  #A validated code should always reference the user that used this code
  def valid_user
    if self.used_flag
      !!self.user
    end
  end

  def generate_token
  	
    if self.code.to_s == ''
      self.code = loop do
      
        random_token = base58(24)
        short_code   = random_token[0..11]

        break short_code unless Events::FeeCode.exists?(code: short_code) and !!/\A\d+\z/.match(short_code)
      end
    end
  end


  # SecureRandom.base58 generates a random base58 string.
  #
  # The argument _n_ specifies the length, of the random string to be generated.
  #
  # If _n_ is not specified or is nil, 16 is assumed. It may be larger in the future.
  #
  # The result may contain alphanumeric characters except 0, O, I and l
  #
  #   p SecureRandom.base58 #=> "4kUgL2pdQMSCQtjE"
  #   p SecureRandom.base58(24) #=> "77TMHrHJFvFDwodq8w7Ev2m7"
  #
  
  BASE58_ALPHABET = ("0".."9").to_a + ("A".."Z").to_a + ("a".."z").to_a - %w(0 O I l)

  def base58(n = 16)
    SecureRandom.random_bytes(n).unpack("C*").map do |byte|
      idx = byte % 64
      idx = SecureRandom.random_number(58) if idx >= 58
      BASE58_ALPHABET[idx]
    end.join
  end  


end
