class User < ApplicationRecord
  attr_accessor :password

  before_save :downcase_email
  before_create :generate_uuid, :create_password_digest

  VALID_NAME_REGEX = /\A[a-zA-Z0-9-]+\z/
  validates :name, format: { with: VALID_NAME_REGEX }, uniqueness: true, presence: true, length: { maximum: 30 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze
  validates :email, presence: true, length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, on: :create

  # トークンを生成
  # TODO: もヂュ―るかしても良いかもしれん
  def self.new_token
    SecureRandom.hex(64)
  end

  # ハッシュ化する
  # TODO: モジュール化しても良いかも
  def self.digest(string)
    Digest::SHA256.hexdigest(string)
  end

  # パスワードを暗号化して代入する
  def create_password_digest
    self.password_digest = User.digest(password)
  end

  # パスワードを更新する
  def update_password(new_password)
    self.password = new_password
    if valid?(:create)
      create_password_digest
      save
    else
      false
    end
  end

  private

  # メールアドレスをすべて小文字にする
  def downcase_email
    self.email = email.downcase
  end

  # uuidを生成して代入する
  def generate_uuid
    100.times do
      @uuid = SecureRandom.uuid
      break unless User.find_by(id: @uuid)
    end
    self.id = @uuid
  end
end