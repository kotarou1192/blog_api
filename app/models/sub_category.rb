class SubCategory < ApplicationRecord
  NAME_MAX_CHARS = 30
  validates :name, length: { maximum: NAME_MAX_CHARS }, presence: true, uniqueness: true
  belongs_to :category
  has_many :post_categories

  def to_data
    {
      id: id,
      base_category_name: category.name,
      sub_category_name: name
    }
  end
end
