class CreateLoginSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :login_sessions do |t|
      t.string :user_id
      t.string :token_digest
      t.string :session_id
      t.timestamps
    end
    add_foreign_key :login_sessions, :users, column: :user_id, primary_key: :id
  end
end
