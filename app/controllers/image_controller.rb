class ImageController < ApplicationController
  include Authenticate

  # upload user image
  def create
    return authenticate_failed unless authenticated?
    return authenticate_failed if @user.name == 'guest'

    result = @user.upload_image(img_params.require(:image))
    return render json: { message: 'success', url: result } if result

    render status: 400, json: { message: 'failed' }
  end

  # delete icon
  def remove_icon
    return authenticate_failed unless authenticated?
    return authenticate_failed if @user.name == 'guest'

    @user.icon.purge
    return render json: { message: :success } unless @user.icon.attached?

    render status: 400, json: { message: 'failed' }
  end

  private

  def img_params
    params.permit(:image)
  end
end
