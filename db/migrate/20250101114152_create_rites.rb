class CreateRites < ActiveRecord::Migration[8.0]
  def change
    create_table :rites do |t|
      t.integer :name, null: false

      t.timestamps
    end

    create_table :dungeon_rites do |t|
      t.references :dungeon, null: false, foreign_key: true
      t.references :rite, null: false, foreign_key: true

      t.timestamps
    end
    add_index :dungeon_rites, [ :dungeon_id, :rite_id ], unique: true
  end
end
