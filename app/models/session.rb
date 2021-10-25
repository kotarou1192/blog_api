class Session < ApplicationRecord
  before_create :generate_session_id
  DEFAULT_EXPIRATION_DAYS = 30
  EXPIRATION_DAYS = nil
  belongs_to :user

  def self.new_token
    SecureRandom.hex(64)
  end

  def still_valid?
    limit = EXPIRATION_DAYS || DEFAULT_EXPIRATION_DAYS
    created_at > limit.days.ago
  end

  private

  def generate_session_id
    100.times do
      @token = UserCreationSession.new_token
      break unless UserCreationSession.find_by(session_id: @token)
    end
    self.session_id = @token
  end
end
