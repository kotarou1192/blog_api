class CreateSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :sessions do |t|
      t.references :user
      t.string :session_id
      t.timestamps
    end
  end
end
