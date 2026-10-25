require "test_helper"

class RiteTest < ActiveSupport::TestCase
  test "should be invalid without a name" do
    assert_not Rite.new(name: nil).valid?
  end

  test "should raise on unknown name" do
    assert_raises(ArgumentError) { Rite.new(name: "unknown") }
  end

  test "translated_name should return localized rite name" do
    expected = { fetid: "死臭", rotted: "腐臭", cursed: "呪い", sinister: "不吉" }
    expected.each do |name, translated|
      assert_equal translated, rites(name).translated_name
    end
  end
end
