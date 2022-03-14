class SearchPostsController < ApplicationController
  include Authenticate
  DEFAULT_MAX_CONTENTS = 50
  MAX_BODY_CHARS = 100

  def index
    authenticated?

    page = search_params[:page].blank? ? 1 : search_params[:page].to_i
    max_contents = search_params[:max_contents].blank? ? DEFAULT_MAX_CONTENTS : search_params[:max_contents].to_i

    results = Post.search(search_keywords, page, max_contents, order: order_type).map { |post| to_hash(post) }
    render json: results
  end

  private

  def search_keywords
    return [] if search_params[:keywords].blank?

    search_params[:keywords].split(/[[:blank:]]/).map do |keyword|
      "%#{keyword}%"
    end
  end

  def to_hash(post)
    {
      user_name: post.user_name,
      id: post.id,
      user_avatar: post.icon_key,
      title: post.title,
      body: post.body.slice(0, MAX_BODY_CHARS),
      created_at: post.created_at.to_i
    }
  end

  ORDER_TYPES = %w[new old matched].freeze
  def order_type
    type = search_params[:order_type]
    return type if ORDER_TYPES.any? type

    'matched'
  end

  def search_params
    params.permit(:keywords, :page, :max_contents, :order_type)
  end
end
