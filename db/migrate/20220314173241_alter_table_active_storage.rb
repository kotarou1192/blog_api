class AlterTableActiveStorage < ActiveRecord::Migration[6.0]
  def change
    remove_column :active_storage_attachments, :record_id, :string, null: false, polymorphic: true, index: false
    add_column :active_storage_attachments, :record_id, :string, null: false, polymorphic: true, index: false
    add_foreign_key :active_storage_attachments, :users, column: :record_id, primary_key: :id
  end
end
