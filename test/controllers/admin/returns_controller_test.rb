require "test_helper"

class Admin::ReturnsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_returns_index_url
    assert_response :success
  end

  test "should get mark_returned" do
    get admin_returns_mark_returned_url
    assert_response :success
  end
end
