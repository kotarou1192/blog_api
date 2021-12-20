class LoginSessionCleanupJob < ApplicationJob
  queue_as :default

  # @param
  # session: LoginSession
  # @return
  # TrueClass FalseClass
  def perform(session_id)
    session = LoginSession.find_by(session_id: session_id)
    session&.destroy
  end
end
