class Post < ApplicationRecord
  TITLE_MAX_CHARS = 255
  BODY_MAX_CHARS = 6000
  DEFAULT_TITLE = 'NoTitle'.freeze

  belongs_to :user

  before_save :set_default_title
  validates :title, length: { maximum: TITLE_MAX_CHARS }
  validates :body, presence: true, length: { maximum: BODY_MAX_CHARS }

  private

  def set_default_title
    self.title = DEFAULT_TITLE if title.blank?
  end
end
