
# Test and Development
if Rails.env.test? || Rails.env.development?
	Braintree::Configuration.environment = :sandbox
	Braintree::Configuration.logger = Logger.new(STDOUT)
	Braintree::Configuration.merchant_id = ENV['BRAINTREE_SANDBOX_MERCHANT_ID']
	Braintree::Configuration.public_key = ENV['BRAINTREE_SANDBOX_PUBLIC_KEY']
	Braintree::Configuration.private_key = ENV['BRAINTREE_SANDBOX_PRIVATE_KEY']

# Production	
else
	Braintree::Configuration.environment = :production
	Braintree::Configuration.logger = Logger.new(STDOUT)
	Braintree::Configuration.merchant_id = ENV['BRAINTREE_PRODUCTION_MERCHANT_ID']
	Braintree::Configuration.public_key = ENV['BRAINTREE_PRODUCTION_PUBLIC_KEY']
	Braintree::Configuration.private_key = ENV['BRAINTREE_PRODUCTION_PRIVATE_KEY']
end


