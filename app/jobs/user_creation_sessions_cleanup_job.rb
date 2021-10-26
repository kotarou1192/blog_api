class UserCreationSessionsCleanupJob < ApplicationJob
  queue_as :default

  def perform(session)
    session.destroy
  end
end
