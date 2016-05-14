class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :etype, null: false

      t.string :name, null: false
      t.string :slogen, default: ""
      t.text :description, default: ""
      t.string :location, default: ""
      t.string :dates, default: ""
      t.string :facebook_url
      t.boolean :published, null: false, default: false
      t.string :agenda
      t.string :contact_email
      t.boolean  :delete_flag, :null => false, :default => false

      t.timestamps null: false
    end
  end
end
