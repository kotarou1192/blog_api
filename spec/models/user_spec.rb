require 'rails_helper'

RSpec.describe User, type: :model do
  @email = 'hoge@email.com'
  @user = User.new(name: 'hoge',
                   email: @email,
                   password: 'hogefuga')
  @user.save

  it 'user should be created' do
    expect(@user.present?).to eq true
  end
end
