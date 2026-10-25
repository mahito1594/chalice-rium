require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "full_title should return base title when page title is empty" do
    assert_equal "Chalice-rium", full_title
    assert_equal "Chalice-rium", full_title("")
  end

  test "full_title should prepend page title" do
    assert_equal "@willem | Chalice-rium", full_title("@willem")
  end

  test "ogp_description should return default description when empty" do
    assert_equal "聖杯ダンジョンをメモできるWebアプリです", ogp_description
    assert_equal "聖杯ダンジョンをメモできるWebアプリです", ogp_description("")
  end

  test "ogp_description should return given description" do
    assert_equal "Fear the Old Blood", ogp_description("Fear the Old Blood")
  end
end
