class LoginController < ApplicationController
  def create
    found_user = User.find_by(email: login_params[:email])
    return render status: 400, json: { message: 'failed' } unless found_user

    if found_user.authenticated?(login_params[:password]) &&
       (@login_session = found_user.login_sessions.create)
      return render json: { token: @login_session.session_id }
    end

    render status: 400, json: { message: 'failed' }
  end

  private

  def login_params
    params.require(:value).permit(:email, :password)
  end
end
