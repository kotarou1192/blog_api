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
  CATEGORY_SCOPES = %w[base sub].freeze

  def self.search(keywords, page, max_content = 50, order: 'matched', category: { ids: [], scope: nil })
    order = ORDER_TYPES_MAP['matched'] unless ORDER_TYPES.any? order
    filtered_post = filter_with_category(category[:scope], category[:ids])
    filtered_post.merge(search_with_keywords(keywords))
                 .order(ORDER_TYPES_MAP[order])
                 .limit(max_content)
                 .offset(max_content * (page - 1))
                 .includes(post_categories: :sub_category, user: { icon_attachment: :blob })
  end

  def update_categories!(sub_category_ids: [])
    related_tags = if sub_category_ids.empty?
                     PostCategory.where(post_id: id)
                   else
                     PostCategory.where(sub_category_id: sub_category_ids, post_id: id)
                   end
    related_ids = related_tags.map(&:sub_category_id)
    transaction do
      # 減っているものを消す
      related_tags.filter do |tag|
        !sub_category_ids.include? tag.sub_category_id
      end.each(&:destroy!)
      # 無いものを足す
      sub_category_ids
        .filter do |id|
        !related_ids.include? id
      end.map do |id|
        sub_cat = SubCategory.find_by(id: id)
        post_categories.new(sub_category_id: sub_cat.id)
      end.each(&:save!)
    end
    true
  end

  def update_categories(sub_category_ids: [])
    related_tags = if sub_category_ids.empty?
                     PostCategory.where(post_id: id)
                   else
                     PostCategory.where(sub_category_id: sub_category_ids, post_id: id)
                   end
    related_ids = related_tags.map(&:sub_category_id)
    transaction do
      # 減っているものを消す
      related_tags.filter do |tag|
        !sub_category_ids.include? tag.sub_category_id
      end.each(&:destroy!)
      # 無いものを足す
      sub_category_ids
        .filter do |id|
          !related_ids.include? id
        end.map do |id|
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
      categories: if post_categories.empty?
                    []
                  else
                    post_categories.map do |p_category|
                      { tag_id: p_category.id, value: p_category.sub_category.to_data }
                    end
                  end,
      title: title,
      body: full_body ? body : body.slice(0, MAX_BODY_CHARS),
      created_at: created_at.to_i,
      updated_at: updated_at.to_i
    }
  end

  private

  def self.filter_with_category(category_scope, ids)
    return Post unless CATEGORY_SCOPES.any? category_scope

    cat_ids = if category_scope == 'base'
                bases = Category.where(id: ids)
                return Post if bases.empty?

                bases.map { |base| base.sub_categories.map(&:id) }.flatten
              else
                sub = SubCategory.where(id: ids)
                return Post if sub.empty?

                sub.where(id: ids).map(&:id)
              end
    categorized_post_ids = PostCategory.where(sub_category_id: cat_ids).map(&:post_id).uniq
    Post.where(id: categorized_post_ids)
  end

  def set_default_title
    self.title = DEFAULT_TITLE if title.blank?
  end

  def self.search_with_keywords(keywords)
    keyword = keywords.shift
    posts = Post.where('title LIKE ?', keyword).or(Post.where('body LIKE ?', keyword))

    return posts if keywords.size.zero?

    posts.or(search_with_keywords(keywords))
  end
end
