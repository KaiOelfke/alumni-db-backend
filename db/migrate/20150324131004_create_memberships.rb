class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.boolean :is_admin,  :default => true
      t.date :join_date,  :null => false
      t.boolean :group_email_subscribed,  :default => true
      t.string :position 
      t.belongs_to :user, index: true
      t.belongs_to :group, index: true
      
      t.timestamps
    end

    add_index :memberships, :join_date

  end
end
