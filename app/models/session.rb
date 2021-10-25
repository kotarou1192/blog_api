class Session < ActiveRecord::Base
  self.abstract_class = true

  before_create :generate_session_id
  after_initialize :set_expiration_days

  DEFAULT_EXPIRATION_DAYS = 30

  def self.new_token
    SecureRandom.hex(64)
  end

  def still_valid?
    limit = @expiration_days || DEFAULT_EXPIRATION_DAYS
    self.created_at > limit.days.ago
  end

  def date_limit
    Time.current.since(@expiration_days.days)
  end

  private

  # set days to delete
  # implement it
  #
  # @expiration_days = Integer
  #
  def set_expiration_days
    raise NotImplementedError, 'use set_expiration_days(number)'

    @expiration_days = nil
  end

  def generate_session_id
    100.times do
      @token = self.class.new_token
      break unless self.class.find_by(session_id: @token)
    end
    self.session_id = @token
  end
end
