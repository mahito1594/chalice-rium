require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test "should get about" do
    get about_path
    assert_response :success
  end

  test "should get terms" do
    get terms_path
    assert_response :success
  end

  test "should get health check" do
    get rails_health_check_path
    assert_response :success
  end
end
