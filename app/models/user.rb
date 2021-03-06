class User < ApplicationRecord
  # https://railsguides.jp/active_storage_overview.html
  has_one_attached :icon
  attr_accessor :password

  has_many_attached :images

  EXP_CHAR_NUMBERS = 255
  MAX_ICON_SIZE = 2

  before_save :downcase_email
  before_create :generate_uuid, :create_password_digest

  VALID_NAME_REGEX = /\A[a-zA-Z0-9-]+\z/.freeze
  validates :name, format: { with: VALID_NAME_REGEX }, uniqueness: true, presence: true, length: { maximum: 30 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  validates :explanation, length: { maximum: EXP_CHAR_NUMBERS }, allow_nil: true
  validates :icon, attached_file_size: { maximum: MAX_ICON_SIZE.megabytes },
                   attached_file_type: { types: %w[image/png image/jpeg image/jpg image/gif] }

  has_many :login_sessions
  has_many :posts

  # トークンを生成
  # TODO: もヂュ―るかしても良いかもしれん
  def self.new_token
    SecureRandom.hex(64)
  end

  def self.search(keywords, page, max_content = 50)
    User.with_attached_icon.search_with_keywords(keywords)
        .limit(max_content)
        .offset(max_content * (page - 1))
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

  def authenticated?(raw_password)
    password_digest == User.digest(raw_password)
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

  # 画像をアップロードする
  def upload_image(img_from_params)
    img = to_blob img_from_params, max_width: 1800, max_height: 900, key_prefix: "#{name}/uploads"
    images.attach(img)
    img.key
  rescue ActiveSupport => e
    false
  end

  def update_with_icon(params)
    transaction do
      update!(explanation: params[:explanation]) if params[:explanation]

      if params[:icon]
        img = to_blob params[:icon]
        raise ArgumentError, 'icon is invalid' unless icon.attach(img)

        update!(icon_key: icon.key)
      end

    rescue StandardError => e
      logger.warn 'user.rb:update_with_icon in rescue' << e.message
      return false
    end
    true
  end

  def to_response_data
    {
      uuid: id,
      name: name,
      explanation: explanation || '',
      icon: icon.attached? ? icon.key : ''
    }
  end

  private

  def to_blob(file, max_width: 800, max_height: 400, key_prefix: 'icons')
    if Rails.configuration.active_storage.service == :amazon
      key = "#{key_prefix}/#{SecureRandom.uuid}.#{ext_from_content_type(file)}"
      blob = ActiveStorage::Blob.new(key: key,
                                     filename: file.original_filename, content_type: file.content_type)
      tmp = ImageProcessing::MiniMagick.source(file).resize_to_limit(max_width, max_height).call
      blob.upload tmp.to_io

      blob
    else
      file
    end
  end

  def ext_from_content_type(file)
    type = file.content_type
    result = type.match(%r{/.+$})
    base = result.nil? ? '' : result[0]
    base[%r{/}] = ''
    base
  end

  def self.search_with_keywords(keywords, index = 0)
    keyword = keywords[index]
    users = User.where('name LIKE ?', keyword).or(User.where('explanation LIKE ?', keyword))

    return users if keywords.size - 1 <= index

    users.or(search_with_keywords(keywords, index + 1))
  end

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
