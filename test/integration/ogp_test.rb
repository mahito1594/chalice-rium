require "test_helper"

class OgpTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:willem)
    @dungeon = dungeons("9kv8xiyi")
  end

  test "should ogp included in user show page" do
    get user_path(@user)
    assert_response :success

    assert_select "meta[property='og:title'][content=?]", "#{@user.username} | Chalice-rium"
    assert_select "meta[property='og:type'][content=?]", "article"
    assert_select "meta[property='og:description']"
    assert_select "meta[property='og:url'][content=?]", user_url(@user)
    assert_select "meta[property='og:image']"
  end

  test "should ogp included in dungeon show page" do
    get dungeon_path(@dungeon)
    assert_response :success

    assert_select "meta[property='og:title'][content=?]", "#{@dungeon.glyph} | Chalice-rium"
    assert_select "meta[property='og:type'][content=?]", "article"
    assert_select "meta[property='og:description']"
    assert_select "meta[property='og:url'][content=?]", dungeon_url(@dungeon)
    assert_select "meta[property='og:image']"
  end
end
