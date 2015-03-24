class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :description
      t.string :picture
      t.string :name
      t.boolean :group_email_enabled

      t.timestamps
    end

    add_index :groups, :name
  end
end
