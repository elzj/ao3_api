class CreateDrafts < ActiveRecord::Migration[6.0]
  def change
    create_table :drafts do |t|
      t.integer :user_id, null: false, foreign_key: true
      t.json :metadata
      t.text :media_data
      t.boolean :marked_for_deletion, null: false, default: false
    end
  end
end
