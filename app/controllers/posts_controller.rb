class PostsController < ApplicationController
  include Authenticate

  before_action :pick_user
  before_action :pick_post, only: %i[show update destroy]

  def index
    return user_not_found_error unless @target_user

    posts = @target_user.posts.order('created_at DESC').map(&:to_response_data)

    render json: posts
  end

  def show
    return user_not_found_error unless @target_user
    return post_not_found_error unless @post

    render json: @post.to_response_data(full_body: true)
  end

  def create
    return user_not_found_error unless @target_user
    return authenticate_failed unless authenticated?
    return authenticate_failed if @user != @target_user

    new_post = @target_user.posts.new(post_create_params)
    new_post.transaction do
      new_post.save!
      new_post.update_categories!(sub_category_ids: post_params[:sub_category_ids]) if post_params[:sub_category_ids]
    rescue ActiveRecord::RecordInvalid => e
      logger.warn e.message
      return render json: { message: 'creation failed' }, status: 400
    end
    render json: { message: 'success' }
  end

  def update
    return user_not_found_error unless @target_user
    return post_not_found_error unless @post
    return authenticate_failed unless authenticated?
    return authenticate_failed if @user != @target_user

    @post.transaction do
      @post.update!(post_params.permit(:title, :body).to_h)
      @post.update_categories!(sub_category_ids: post_params[:sub_category_ids] || [])
    rescue ActiveRecord::RecordInvalid => e
      logger.warn e.message
      return render json: { message: 'update failed' }, status: 400
    end
    render json: { message: 'success' }
  end

  def destroy
    return user_not_found_error unless @target_user
    return post_not_found_error unless @post
    return authenticate_failed unless authenticated?
    return authenticate_failed unless @user.id == @target_user.id && @post.user.id == @user.id

    return render json: { message: 'success' } if @post.destroy

    render json: { message: 'failed to destroy' }, status: 400
  end

  private

  def post_not_found_error
    render json: { message: "the post id: #{allowed_params[:id]} does not exist." }, status: :not_found
  end

  def user_not_found_error
    render json: { message: "the user: #{allowed_params[:user_name]} does not exist." }, status: :not_found
  end

  def pick_user
    @target_user = User.find_by(name: allowed_params[:user_name])
  end

  def pick_post
    @post = Post.find_by(id: allowed_params[:id].to_i)
  end

  # used from error_response and pick_{name}
  def allowed_params
    params.permit(:title, :body, :user_name, :id, :post_id)
  end

  def post_params
    params.permit(:body, :title, sub_category_ids: [])
  end

  def post_create_params
    params.permit(:body, :title)
  end
end
