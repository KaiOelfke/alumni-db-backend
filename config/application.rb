require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AlumniDbBackend
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de


    config.member_countries = ['BG','DK','EE','DE','SE','CH','IT','LT','PT','FI','ES','NO','AT','RS','CZ','BE','GR','NL','MT','SK','FR','LU','PL']
    config.generators do |g|
        g.fixture_replacement :factory_girl
    end
    
    config.active_record.raise_in_transactional_callbacks = true
    config.active_record.schema_format = :sql

    config.autoload_paths += Dir["#{config.root}/lib/**/"]
    
  end
end


