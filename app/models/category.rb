class Category < ApplicationRecord
  NAME_MAX_CHARS = 30
  validates :name, length: { maximum: NAME_MAX_CHARS }, presence: true, uniqueness: true

  has_many :sub_categories
end
