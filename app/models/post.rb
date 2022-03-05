class Post < ApplicationRecord
  TITLE_MAX_CHARS = 255
  BODY_MAX_CHARS = 6000
  DEFAULT_TITLE = 'NoTitle'.freeze
  RESULT = 'result'.freeze

  belongs_to :user

  before_save :set_default_title
  validates :title, length: { maximum: TITLE_MAX_CHARS }
  validates :body, presence: true, length: { maximum: BODY_MAX_CHARS }

  ORDER_TYPES = %w[new old matched].freeze
  ORDER_TYPES_MAP = {
    'new'.freeze => "ORDER BY #{RESULT}.created_at desc",
    'old'.freeze => "ORDER BY #{RESULT}.created_at asc",
    'matched'.freeze => 'ORDER BY count(*) desc'
  }
  def self.search(keywords, page, max_content = 50, order: 'matched')
    order = ORDER_TYPES_MAP['matched'] unless ORDER_TYPES.any? order
    Post.find_by_sql(['SELECT id, out.user_name, title, body, created_at FROM (' <<
      Post.arel_table
          .project("#{RESULT}.id", "#{RESULT}.title", "#{RESULT}.body", "#{RESULT}.created_at, #{RESULT}.user_name")
          .from(search_with_keywords(keywords).as(RESULT))
          .group("#{RESULT}.id", "#{RESULT}.title", "#{RESULT}.body", "#{RESULT}.created_at, #{RESULT}.user_name")
          .to_sql << " #{ORDER_TYPES_MAP[order]} ) AS out LIMIT ? OFFSET ?", max_content, max_content * (page - 1)])
  end

  private

  def set_default_title
    self.title = DEFAULT_TITLE if title.blank?
  end

  def self.search_with_keywords(keywords, index = 0)
    keyword = keywords[index]
    uposts = Arel::Table.new :uposts
    post = Post.arel_table
    posts = post.project('uposts.u_name as user_name, uposts.id, uposts.title, uposts.body, uposts.created_at')
                .from('((select id as uuid, name as u_name from users) as author INNER JOIN posts ON author.uuid = posts.user_id) as uposts')
                .where(uposts[:title].matches(keyword)
                    .or(uposts[:body].matches(keyword)))

    return posts if keywords.size - 1 <= index

    Arel::Nodes::UnionAll.new(posts, search_with_keywords(keywords, index + 1))
  end
end
