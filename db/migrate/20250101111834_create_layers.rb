class CreateLayers < ActiveRecord::Migration[8.0]
  def change
    create_table :layers do |t|
      t.references :dungeon, null: false, foreign_key: true
      t.integer :level, null: false
      t.string :boss_name

      t.timestamps
    end
    add_index :layers, [ :dungeon_id, :level ], unique: true
  end
end
