class UsersController < ApplicationController
  def create
    creation_session = UserCreationSession.find_by(session_id: user_creation_params[:session_id])
    email = creation_session.email
    @user = User.new({email: email, password: user_creation_params[:password], name: user_creation_params[:name]})

    if @user.save
      render json: {message: 'created your account successfully'}
    else
      # TODO: エラーメッセージを正確に
      # TODO: レスポンスのjsonの形式の統一
      render status: 400, json: { message: 'failed to create your account' }
    end
  end

  private

  def user_creation_params
    return {} if params[:value].nil?

    params.require(:value).permit(:session_id, :password, :name)
  end
end
