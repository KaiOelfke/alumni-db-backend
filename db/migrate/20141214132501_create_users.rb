class CreateUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      ## Database authenticatable
      t.string :email, :null => false
      t.string :encrypted_password, :null => false, :default => ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, :default => 0, :null => false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, :default => 0, :null => false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      ## Personal data
      t.string :first_name
      t.string :last_name
      t.string :country
      t.string :city
      t.date :date_of_birth
      t.integer :gender, :default => 0

      ## JA-YE Data
      t.integer :program_type, :default => 0
      t.string :institution
      t.integer :year_of_participation
      t.string :country_of_participation
      t.string :student_company_name

      ## Optional personal info
      t.string :university_name
      t.string :university_major
      t.string :founded_company_name
      t.string :current_company_name
      t.string :current_job_position
      t.string :interests
      t.string :short_bio

      ## Alumni
      #t.boolean :active_member
      t.string :alumni_position ##Position in network e.g. regional coordinator
      t.date :member_since
      ##t.boolean? :subscibed_newsletter

      ##Contact data
      t.string :facebook_url
      t.string :skype_id
      t.string :twitter_url
      t.string :linkedin_url
      t.string :mobile_phone

      ##Avatar and cover url
      t.string :avatar
      t.string :cover

      ## unique oauth id
      t.string :provider
      t.string :uid, :null => false, :default => ""

      ## Tokens
      t.text :tokens

      ## Role management

      t.boolean :registered
      t.boolean :confirmed_email
      t.boolean :completed_profile

      t.timestamps
    end

    add_index :users, :email
    add_index :users, :uid,                  :unique => true
    add_index :users, :reset_password_token, :unique => true
    add_index :users, :confirmation_token,   :unique => true
    # add_index :users, :unlock_token,         :unique => true
  end
end
