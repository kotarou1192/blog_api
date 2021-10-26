class CreateLoginSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :login_sessions do |t|
      t.references :user
      t.string :token_digest
      t.string :session_id
      t.timestamps
    end
  end
end
