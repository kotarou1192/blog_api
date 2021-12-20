class UserCreationSessionsCleanupJob < ApplicationJob
  queue_as :default

  def perform(session_id)
    session = UserCreationSession.find_by(session_id: session_id)
    session&.destroy
  end
end
