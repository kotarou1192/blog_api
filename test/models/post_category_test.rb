require 'test_helper'

class PostCategoryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @user = User.find_by(name: 'test-user')
    @post = @user.posts.create(title: 'this is it', body: 'this is that')
    test_category = %w[a b c d e f g h i j k l m n o p q r s t u]
    cat = Category.create(name: 'test cat')
    test_category.each do |name|
      cat.sub_categories.create(name: name)
    end
    @categories = PostCategory.all_categories.map(&:to_data)
  end

  test 'should be created' do
    id = @categories[0][:id]
    assert @post.update_categories(sub_category_ids: [id])
  end

  test 'should be non effected' do
    id = @categories[0][:id]
    @post.update_categories(sub_category_ids: [id])
    @post.update_categories(sub_category_ids: [id])
    assert @post.post_categories.size == 1
  end

  test 'too manu categories should be rejected' do
    ids = @categories[0..10].map { |cat| cat[:id] }
    assert_not @post.update_categories(sub_category_ids: ids)
  end
end
