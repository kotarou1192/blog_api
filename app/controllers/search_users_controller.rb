class SearchUsersController < ApplicationController
  include Authenticate
  DEFAULT_MAX_CONTENTS = 50

  def index
    authenticated?

    page = search_params[:page].blank? ? 1 : search_params[:page].to_i
    max_contents = search_params[:max_contents].blank? ? DEFAULT_MAX_CONTENTS : search_params[:max_contents].to_i

    results = User.search(search_keywords, page, max_contents).map { |user| to_hash(user) }
    render json: results
  end

  private

  def search_keywords
    return [] if search_params[:keywords].blank?

    search_params[:keywords].split(/[[:blank:]]/).map do |keyword|
      "%#{keyword}%"
    end
  end

  def to_hash(user)
    {
      name: user.name
    }
  end

  def search_params
    params.permit(:keywords, :page, :max_contents)
  end
end
