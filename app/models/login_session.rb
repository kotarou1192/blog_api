class LoginSession < Session
  after_create :cleanup
  belongs_to :user
  MAX_SESSION_NUMBERS = 10

  validate :sessions_numbers_limit

  private

  # 有効期限
  def set_expiration_days
    @expiration_days = 30
  end

  # 規定時間後に削除
  def cleanup
    LoginSessionCleanupJob.set(wait_until: date_limit).perform_later(self)
  end

  def sessions_numbers_limit
    result = user.login_sessions.count <= MAX_SESSION_NUMBERS
    errors.add :base, 'too many login_sessions' unless result
    result
  end
end
