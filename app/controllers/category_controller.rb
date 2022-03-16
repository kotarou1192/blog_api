class CategoryController < ApplicationController
  def index
    categories = Category.all
    category_list = categories.map do |category|
      [category.name, category.sub_categories.map(&:to_data)]
    end.to_h
    render json: category_list
  end
end
