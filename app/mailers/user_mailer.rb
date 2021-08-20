class UserMailer < ApplicationMailer
  PROTOCOL = 'https'
  DOMAIN = 'takashiii-hq.com'

  def account_creation_mail(account_creation_session)
    @account_creation_url = url_with_params("#{PROTOCOL}://#{DOMAIN}/account/create", session_id: account_creation_session.session_id)
    mail to: account_creation_session.email
  end
end
