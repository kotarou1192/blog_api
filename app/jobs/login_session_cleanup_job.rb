class LoginSessionCleanupJob < ApplicationJob
  queue_as :default

  # @param
  # session: LoginSession
  # @return
  # TrueClass FalseClass
  def perform(session)
    session.destroy
  end
end
