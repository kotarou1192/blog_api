class PostCategory < ApplicationRecord
  belongs_to :post
  has_and_belongs_to_many :sub_categories
  validate :less_than_limit?
  validate :all_uniq?
  MAXIMUM_CATEGORY_NUMS = 10

  def self.all_categories
    SubCategory.all.includes(:category)
  end

  private

  def less_than_limit?
    if post.post_categories && post.post_categories.size > MAXIMUM_CATEGORY_NUMS
      errors.add(:post_categories, 'too many categories')
    end
  end

  def all_uniq?
    if post.post_categories
      mapper = {}
      return unless post.post_categories.any? do |category|
        next true if mapper[category.sub_category_id]

        mapper[category.sub_category_id] ||= true
      end

      errors.add(:post_categories, 'must be unique')
    end
  end
end
