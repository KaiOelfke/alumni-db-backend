class Events::FeeCode < ActiveRecord::Base

  belongs_to :fee
  belongs_to :user

  before_validation :generate_token

	validates :code, :fee, :user, presence: true
  validates_uniqueness_of :code


  private

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
