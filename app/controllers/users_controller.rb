class UsersController < ApplicationController
  include Authenticate

  def create
    creation_session = UserCreationSession.find_by(session_id: user_creation_params[:session_id])
    return render status: 400, json: { message: 'failed to create your account' } unless creation_session

    email = creation_session.email
    @user = User.new({ email: email, password: user_creation_params[:password], name: user_creation_params[:name] })

    if @user.save
      render json: { message: 'created your account successfully' }
    else
      # TODO: エラーメッセージを正確に
      # TODO: レスポンスのjsonの形式の統一
      render status: 400, json: { message: 'failed to create your account' }
    end
  end

  def show
    authenticated?
    user = User.find_by(name: user_name)
    return render json: { error: { message: ['not found'] } }, status: :not_found unless user

    render json: user.to_response_data.merge({ is_my_page: @user ? user.id == @user.id : false })
  end

  def update
    return authenticate_failed unless authenticated?

    return render json: { massage: 'updated your account' } if @user.update_with_icon(user_params)

    render status: 400, json: { messages: @user.errors.messages }
  end

  def _delete
    return authenticate_failed unless authenticated?

    return render json: { massage: 'updated your account' } if @user.destroy

    render status: 400, json: { messages: @user.errors.messages }
  end

  private

  def user_params
    params.permit(:explanation, :icon)
  end

  def user_creation_params
    return {} if params[:value].nil?

    params.require(:value).permit(:session_id, :password, :name)
  end

  def user_name
    params.permit(:id)[:id]
  end
end
