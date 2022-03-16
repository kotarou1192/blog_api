class Post < ApplicationRecord
  TITLE_MAX_CHARS = 255
  BODY_MAX_CHARS = 6000
  DEFAULT_TITLE = 'NoTitle'.freeze
  RESULT = 'result'.freeze
  MAX_BODY_CHARS = 100

  belongs_to :user
  has_many :post_categories, dependent: :destroy

  before_save :set_default_title
  validates :title, length: { maximum: TITLE_MAX_CHARS }
  validates :body, presence: true, length: { maximum: BODY_MAX_CHARS }

  ORDER_TYPES = %w[new old matched].freeze
  ORDER_TYPES_MAP = {
    'new'.freeze => 'created_at desc',
    'old'.freeze => 'created_at asc',
    'matched'.freeze => ''
  }.freeze
  def self.search(keywords, page, max_content = 50, order: 'matched')
    order = ORDER_TYPES_MAP['matched'] unless ORDER_TYPES.any? order
    Post.search_with_keywords(keywords)
        .order(ORDER_TYPES_MAP[order])
        .limit(max_content)
        .offset(max_content * (page - 1)).includes(user: { icon_attachment: :blob })
  end

  def add_categories!(sub_category_ids: [])
    transaction do
      sub_category_ids.map do |id|
        sub_cat = SubCategory.find_by(id: id)
        post_categories.new(sub_category_id: sub_cat.id)
      end.each(&:save!)
    end
    true
  end

  def add_categories(sub_category_ids: [])
    transaction do
      sub_category_ids.map do |id|
        sub_cat = SubCategory.find_by(id: id)
        post_categories.new(sub_category_id: sub_cat.id)
      end.each(&:save!)
    rescue ActiveRecord::RecordInvalid => e
      logger.warn e
      return false
    end
    true
  end

  def to_response_data(full_body: false)
    {
      id: id,
      user_id: user_id,
      user_name: user.name,
      user_avatar: user.icon.attached? ? user.icon.key : '',
      categories: post_categories.empty? ? [] : post_categories.map { |p_category| p_category.sub_category.to_data },
      title: title,
      body: full_body ? body : body.slice(0, MAX_BODY_CHARS),
      created_at: created_at.to_i,
      updated_at: updated_at.to_i
    }
  end

  private

  def set_default_title
    self.title = DEFAULT_TITLE if title.blank?
  end

  def self.search_with_keywords(keywords, index = 0)
    keyword = keywords[index]
    posts = Post.where('title LIKE ?', keyword).or(Post.where('body LIKE ?', keyword))

    return posts if keywords.size - 1 <= index

    posts.or(search_with_keywords(keywords, index + 1))
  end
end
