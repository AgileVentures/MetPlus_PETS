class CreateStatusChanges < ActiveRecord::Migration
  def change
    create_table :status_changes do |t|
      t.integer :status_change_to
      t.integer :status_change_from, null: true
      
      t.references :entity, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
