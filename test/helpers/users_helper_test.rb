require "test_helper"

class UsersHelperTest < ActionView::TestCase
  def setup
    @user = users(:willem)
  end

  test "should render nothing if he/she has no link" do
    assert_nil link_to_twitter_profile(@user)
  end

  test "should render valid twitter link with default class" do
    @user.twitter_link = "willem"
    assert_dom_equal %(<a href="https://x.com/willem" target="_blank" rel="noreferrer noopener" class="text-blue-500 dark:text-blue-400 hover:underline" >@willem</a>),
                     link_to_twitter_profile(@user)
  end

  test "should render valid twitter link with custom class" do
    @user.twitter_link = "willem"
    assert_dom_equal %(<a href="https://x.com/willem" target="_blank" rel="noreferrer noopener" class="custom-class" >@willem</a>),
                     link_to_twitter_profile(@user, class: "custom-class")
  end
end
