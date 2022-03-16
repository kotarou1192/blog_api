class CategoryController < ApplicationController
  def index
    categories = Category.all
    category_list = categories.map do |category|
      [category.name, { category_id: category.id, sub_categories: category.sub_categories.map(&:to_data) }]
    end.to_h
    render json: category_list
  end

  def search
    base = Category.where('name like ?', keyword).limit(10)
    sub = SubCategory.where('name like ?', keyword).limit(10)

    case only
    when 'sub'
      return render json: sub
    when 'base'
      return render json: base
    end

    render json: { base: base, sub: sub }
  end

  private

  def only
    permitted = params.permit(:only)
    filter_str = permitted[:only] || nil
    return filter_str if %w[base sub].any? filter_str

    nil
  end

  def keyword
    key = params.permit(:keyword)[:keyword]
    return '%_%' if key.blank?

    "%#{key}%"
  end
end
