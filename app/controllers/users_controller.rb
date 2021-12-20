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

    render json: user_to_hash(user).merge({ is_my_page: @user ? user.id == @user.id : false })
  end

  private

  def user_to_hash(model)
    {
      uuid: model.id,
      name: model.name
    }
  end

  def user_creation_params
    return {} if params[:value].nil?

    params.require(:value).permit(:session_id, :password, :name)
  end

  def user_name
    params.permit(:id)[:id]
  end
end
