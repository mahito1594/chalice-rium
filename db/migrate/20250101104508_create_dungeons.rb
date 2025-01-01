class CreateDungeons < ActiveRecord::Migration[8.0]
  def change
    create_table :dungeons do |t|
      t.references :user, null: false, foreign_key: true
      t.string :glyph, null: false, limit: 8
      t.integer :depth, null: false
      t.integer :area, null: false
      t.boolean :is_open
      t.text :comment

      t.timestamps
    end
    add_index :dungeons, :glyph, unique: true
  end
end
