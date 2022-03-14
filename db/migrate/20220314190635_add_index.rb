class AddIndex < ActiveRecord::Migration[6.0]
  def change
    add_index :users, %i[name explanation]
    add_index :posts, %i[title body]
  end
end
