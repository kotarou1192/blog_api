require 'test_helper'

class PostCategoryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @user = User.find_by(name: 'test-user')
    @post = @user.posts.create(title: 'this is it', body: 'this is that')
    foods_category = %w[グルメ総合 食べ歩き スイーツ 料理 お酒 外食 レシピ]
    cat = Category.create(name: 'グルメ')
    foods_category.each do |name|
      cat.sub_categories.create(name: name)
    end
    @categories = PostCategory.all_categories.map(&:to_data)
  end

  test 'should be created' do
    id = @categories[0][:id]
    assert @post.add_category(sub_category_ids: [id])
  end

  test 'should be invalid' do
    id = @categories[0][:id]
    @post.add_category(sub_category_ids: [id])
    assert_not @post.add_category(sub_category_ids: [id])
  end

  test 'too manu categories should be rejected' do
    ids = @categories[0..10]
    assert_not @post.add_category(sub_category_ids: ids)
  end
end
