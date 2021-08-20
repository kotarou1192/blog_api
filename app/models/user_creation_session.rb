class UserCreationSession < ApplicationRecord
  before_save :downcase_email
  before_create :generate_session_id

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze
  validates :email, presence: true, length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: true

  def send_account_creation_email
    UserMailer.account_creation_mail(self).deliver_now
  end

  # トークンを生成
  # TODO: もヂュ―るかしても良いかもしれん
  def self.new_token
    SecureRandom.hex(64)
  end

  private

  def generate_session_id
    100.times do
      @token = UserCreationSession.new_token
      break unless UserCreationSession.find_by(session_id: @token)
    end
    self.session_id = @token
  end

  # メールアドレスをすべて小文字にする
  def downcase_email
    self.email = email.downcase
  end
end
