class CreateUserCreationSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :user_creation_sessions do |t|
      t.string :session_id
      t.string :email
      t.timestamps
    end
  end
end
