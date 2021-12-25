class PostsController < ApplicationController
  include Authenticate

  before_action :pick_user
  before_action :pick_post, only: %i[show update destroy]

  def index
    return user_not_found_error unless @target_user

    posts = @target_user.posts.select(:id, :user_id, :created_at, :updated_at, :title).order('created_at DESC').map do |post|
      post_data post
    end

    render json: posts
  end

  def show
    return user_not_found_error unless @target_user
    return post_not_found_error unless @post

    render json: post_data(@post, has_body: true)
  end

  def create
    return user_not_found_error unless @target_user
    return authenticate_failed unless authenticated?
    return authenticate_failed if @user != @target_user

    new_post = @target_user.posts.new(post_params)
    return render json: { message: 'success' } if new_post.save

    render json: { message: 'creation failed' }, status: 400
  end

  def update
    return user_not_found_error unless @target_user
    return post_not_found_error unless @post
    return authenticate_failed unless authenticated?
    return authenticate_failed if @user != @target_user

    return render json: { message: 'success' } if @post.update(post_params.to_h)

    render json: { message: 'update failed' }, status: 400
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

  def post_data(post, has_body: false)
    {
      id: post.id,
      user_id: post.user_id,
      title: post.title,
      created_at: post.created_at.to_i,
      updated_at: post.updated_at.to_i
    }.merge(has_body ? { body: post.body } : {})
  end

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
    @post = Post.find(allowed_params[:id].to_i)
  end

  def allowed_params
    params.permit(:title, :body, :user_name, :id)
  end

  def post_params
    params.permit(:body, :title)
  end
end
