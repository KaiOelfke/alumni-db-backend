class CreateParticipations < ActiveRecord::Migration
  def change
    create_table :participations do |t|
      t.belongs_to :fee, index: true
      t.belongs_to :user, index: true

      t.timestamps null: false
    end

    add_foreign_key :participations, :fees, on_delete: :cascade
    add_foreign_key :participations, :users, on_delete: :cascade

  end
end
