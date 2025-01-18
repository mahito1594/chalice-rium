class AddBiographyToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :bio, :text
    add_column :users, :twitter_link, :string
  end
end
