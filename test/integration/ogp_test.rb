require "test_helper"

class OgpTest < ActionDispatch::IntegrationTest
  DEFAULT_DESCRIPTION = "聖杯ダンジョンをメモできるWebアプリです".freeze

  def setup
    @user = users(:willem)
    @dungeon = dungeons("9kv8xiyi")
  end

  test "should ogp included in top page" do
    get root_path
    assert_response :success

    assert_select "meta[property='og:title'][content=?]", "Chalice-rium"
    assert_select "meta[property='og:type'][content=?]", "website"
    assert_select "meta[property='og:description'][content=?]", DEFAULT_DESCRIPTION
  end

  test "should ogp included in user show page" do
    get user_path(@user)
    assert_response :success

    assert_select "meta[property='og:title'][content=?]", "#{@user.username} | Chalice-rium"
    assert_select "meta[property='og:type'][content=?]", "article"
    assert_select "meta[property='og:description'][content=?]", DEFAULT_DESCRIPTION
    assert_select "meta[property='og:url'][content=?]", user_url(@user)
    assert_select "meta[property='og:image']"
  end

  test "should use user bio as og:description" do
    @user.update!(bio: "Fear the Old Blood")

    get user_path(@user)
    assert_select "meta[property='og:description'][content=?]", "Fear the Old Blood"
  end

  test "should ogp included in dungeon show page" do
    get dungeon_path(@dungeon)
    assert_response :success

    assert_select "meta[property='og:title'][content=?]", "#{@dungeon.glyph} | Chalice-rium"
    assert_select "meta[property='og:type'][content=?]", "article"
    assert_select "meta[property='og:description'][content=?]", DEFAULT_DESCRIPTION
    assert_select "meta[property='og:url'][content=?]", dungeon_url(@dungeon)
    assert_select "meta[property='og:image']"
  end

  test "should use dungeon comment as og:description" do
    @dungeon.update!(comment: "Blood-starved Beast is tough")

    get dungeon_path(@dungeon)
    assert_select "meta[property='og:description'][content=?]", "Blood-starved Beast is tough"
  end
end
