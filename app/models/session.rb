class Session < ActiveRecord::Base
  self.abstract_class = true

  before_create :generate_session_id

  DEFAULT_EXPIRATION_DAYS = 30
  @expiration_days = 1

  def self.new_token
    SecureRandom.hex(64)
  end

  def still_valid?
    limit = @expiration_days || DEFAULT_EXPIRATION_DAYS
    self.created_at > limit.days.ago
  end

  private

  def generate_session_id
    100.times do
      @token = self.class.new_token
      break unless self.class.find_by(session_id: @token)
    end
    self.session_id = @token
  end
end
