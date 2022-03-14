class CreatePostCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :post_categories do |t|
      t.references :category, null: false
      t.references :post
      t.timestamps
    end
  end
end
