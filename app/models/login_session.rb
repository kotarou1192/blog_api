class LoginSession < Session
  after_create :cleanup
  belongs_to :user
  MAX_SESSION_NUMBERS = 10

  before_create :sessions_numbers_limit

  private

  # 有効期限
  def set_expiration_days
    @expiration_days = 30
  end

  # 規定時間後に削除
  def cleanup
    LoginSessionCleanupJob.set(wait_until: date_limit).perform_later(session_id)
  end

  # 制限以上に作成されると古いものを消して更新
  def sessions_numbers_limit
    user.login_sessions.first.destroy if user.login_sessions.count >= MAX_SESSION_NUMBERS
  end
end
