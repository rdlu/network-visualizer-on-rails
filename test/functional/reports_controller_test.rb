require 'test_helper'

class ReportsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get graph" do
    get :graph
    assert_response :success
  end

end
