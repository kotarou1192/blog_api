class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|

      t.references :user, type: :string
      t.string :title, index: true
      t.string :body
      t.timestamps
    end
  end
end
