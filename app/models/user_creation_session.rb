class UserCreationSession < Session
  before_save :downcase_email

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze
  validates :email, presence: true, length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: true

  def send_account_creation_email
    UserMailer.account_creation_mail(self).deliver_now
  end

  private

  # 有効期限
  def set_expiration_days
    @expiration_days = 1
  end

  # メールアドレスをすべて小文字にする
  def downcase_email
    self.email = email.downcase
  end
end
