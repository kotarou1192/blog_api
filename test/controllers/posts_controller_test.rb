require 'test_helper'

class PostsControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
    @jwt = JWT::Provider.new(private_key: 'secret'.freeze)
    @user = User.find_by(name: 'test-user')
    @other_user = User.find_by(name: 'test-user-2')
    @post = Post.find_by(title: 'title_one')
  end

  def response
    JSON.parse @response.body
  end

  def authorize_header
    token = @jwt.generate(name: @user.id, user_name: @user.name, lim_days: 10, sub: 'api_test')
    { Authorization: "Bearer #{token}" }
  end

  test 'any post should be gotten' do
    get "/users/#{@user.name}/posts/#{@post.id}"
    assert response['title'] == @post.title
  end

  test 'any user\'s all posts should be gotten' do
    get "/users/#{@user.name}/posts/"
    assert response.size == @user.posts.size
  end

  test 'be able to post' do
    title = 'test_title'
    body = 'test_body'
    post "/users/#{@user.name}/posts/", params: { title: title, body: body }, headers: authorize_header
    assert @response.status == 200
  end

  test 'be not able to post' do
    title = 'test_title'
    body = 'test_body'
    post "/users/#{@other_user.name}/posts/", params: { title: title, body: body }, headers: authorize_header
    assert @response.status == 401
  end

  test 'be able to edit my post' do
    tmp_post = @user.posts.create(title: 'any', body: 'random')
    title = 'edited_title'
    body = 'edited_body'
    put "/users/#{@user.name}/posts/#{tmp_post.id}", params: { title: title, body: body }, headers: authorize_header

    edited_post = Post.find(tmp_post.id)
    assert edited_post.title == title && edited_post.body == body
  end

  test 'should be able to add category to post' do
    # create categories
    test_category = %w[a b c d e f g h i j k l m n o p q r s t u]
    cat = Category.create(name: 'test cat')
    test_category.each do |name|
      cat.sub_categories.create(name: name)
    end
    categories = SubCategory.all.map(&:id)

    put "/users/#{@user.name}/posts/#{@post.id}", params: { sub_category_ids: categories.shift(5) },
                                                  headers: authorize_header

    edited_post = Post.find(@post.id)
    assert edited_post.post_categories.size == 5
  end

  test 'should be able to remove category to post' do
    # create categories
    test_category = %w[a b c d e f g h i j k l m n o p q r s t u]
    cat = Category.create(name: 'test cat')
    test_category.each do |name|
      cat.sub_categories.create(name: name)
    end
    categories = SubCategory.all.map(&:id)

    put "/users/#{@user.name}/posts/#{@post.id}", params: { sub_category_ids: categories.shift(5) },
                                                  headers: authorize_header

    get "/users/#{@user.name}/posts/#{@post.id}"
    res = JSON.parse @response.body
    cache = res['categories'].dup
    put "/users/#{@user.name}/posts/#{@post.id}", params: { title: @post.title, body: @post.body },
                                                  headers: authorize_header
    get "/users/#{@user.name}/posts/#{@post.id}"
    res = JSON.parse @response.body
    assert_not res['categories'].size == cache.size
  end

  test 'should be able to edit and add category to post' do
    # create categories
    test_category = %w[a b c d e f g h i j k l m n o p q r s t u]
    cat = Category.create(name: 'test cat')
    test_category.each do |name|
      cat.sub_categories.create(name: name)
    end
    categories = SubCategory.all.map(&:id)
    title = 'edited_title'
    body = 'edited_body'

    put "/users/#{@user.name}/posts/#{@post.id}", params: { title: title, body: body, sub_category_ids: categories.shift(5) },
                                                  headers: authorize_header

    edited_post = Post.find(@post.id)
    assert edited_post.post_categories.size == 5 && edited_post.title == title && edited_post.body == body
  end

  test 'be not able to edit other person\'s any post' do
    title = 'edited_title'
    body = 'edited_body'
    put "/users/#{@other_user.name}/posts/#{@post.id}", params: { title: title, body: body }, headers: authorize_header
    assert @response.status == 401
  end

  test 'be able to delete my any post' do
    tmp_post = @user.posts.create(title: 'any', body: 'random')
    delete "/users/#{@user.name}/posts/#{tmp_post.id}", headers: authorize_header
    assert_not Post.find_by(id: tmp_post.id)
  end

  test 'be not able to delete other person\'s any post' do
    not_own_post = @other_user.posts.create(title: 'others_title', body: 'others_body')
    delete "/users/#{@user.name}/posts/#{not_own_post.id}", headers: authorize_header

    assert @response.status == 401
  end
end
