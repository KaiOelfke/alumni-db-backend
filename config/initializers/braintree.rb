Braintree::Configuration.environment = ENV['BRAINTREE_ENV'].to_sym
Braintree::Configuration.logger = Logger.new(STDOUT)
Braintree::Configuration.merchant_id = ENV['BRAINTREE_MERCHANT_ID']
Braintree::Configuration.public_key = ENV['BRAINTREE_PUBLIC_KEY']
Braintree::Configuration.private_key = ENV['BRAINTREE_PRIVATE_KEY']
