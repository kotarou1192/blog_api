class SearchPostsController < ApplicationController
  include Authenticate
  DEFAULT_MAX_CONTENTS = 50

  def index
    authenticated?

    page = search_params[:page].blank? ? 1 : search_params[:page].to_i
    max_contents = search_params[:max_contents].blank? ? DEFAULT_MAX_CONTENTS : search_params[:max_contents].to_i

    results = Post.search(search_keywords, page, max_contents, order: order_type,
                                                               category: {
                                                                 scope: search_params[:category_scope],
                                                                 ids: category_ids
                                                               })
    render json: results.map(&:to_response_data)
  end

  private

  def search_keywords
    return ['%_%'] if search_params[:keywords].blank?

    search_params[:keywords].split(/[[:blank:]]/).map do |keyword|
      "%#{keyword}%"
    end
  end

  def category_ids
    return [] if search_params[:category_ids].blank?

    search_params[:category_ids].split(/[[:blank:]]/).map(&:to_i)
  end

  ORDER_TYPES = %w[new old matched].freeze
  def order_type
    type = search_params[:order_type]
    return type if ORDER_TYPES.any? type

    'matched'
  end

  def search_params
    params.permit(:keywords, :page, :max_contents, :order_type, :category_scope, :category_ids)
  end
end
