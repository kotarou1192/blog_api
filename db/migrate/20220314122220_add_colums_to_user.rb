class AddColumsToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :icon_key, :string
  end
end
