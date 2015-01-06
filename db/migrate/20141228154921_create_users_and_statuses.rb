class CreateUsersAndStatuses < ActiveRecord::Migration
  def change
    create_table :users_statuses, id: false do |t|
      t.belongs_to :user, index: true
      t.belongs_to :status, index: true
    end
  end
end
