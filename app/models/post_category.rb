class PostCategory < ApplicationRecord
  belongs_to :post
  belongs_to :sub_category
  validate :less_than_limit_and_uniq?
  MAXIMUM_CATEGORY_NUMS = 10

  def self.all_categories
    SubCategory.all.includes(:category)
  end

  private

  def less_than_limit_and_uniq?
    less_than_limit? && all_uniq?
  end

  def less_than_limit?
    if post.post_categories.size > MAXIMUM_CATEGORY_NUMS
      errors.add(:post_categories, "is too much. less than #{MAXIMUM_CATEGORY_NUMS}")
      return false
    end
    true
  end

  def all_uniq?
    return true if post.post_categories.empty?

    mapper = {}
    return true if post.post_categories.all? do |category|
                     mapper[category.sub_category_id].nil? && (mapper[category.sub_category_id] = true)
                   end

    errors.add(:post_categories, 'must be unique')
    false
  end
end
