class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.boolean :is_admin
      t.date :join_date
      t.boolean :group_email_subscribed
      t.string :position

      t.timestamps
    end

    add_index :memberships, :join_date

  end
end
