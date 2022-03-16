require 'test_helper'

class CategoryControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  def setup
    @user = User.find_by(name: 'test-user')
    @post = @user.posts.create(title: 'this is it', body: 'this is that')
    @test_category = %w[a b c d e f g h i j k l m n o p q r s t u]
    cat = Category.create(name: 'test cat')
    @test_category.each do |name|
      cat.sub_categories.create(name: name)
    end
    @categories = PostCategory.all_categories.map(&:to_data)
  end

  test 'should be got' do
    get '/categories'
    res = JSON.parse @response.body
    assert res['test cat']['sub_categories'].size == @test_category.size
  end
end
