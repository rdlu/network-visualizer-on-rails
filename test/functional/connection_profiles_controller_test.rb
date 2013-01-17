require 'test_helper'

class ConnectionProfilesControllerTest < ActionController::TestCase
  setup do
    @connection_profile = connection_profiles(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:connection_profiles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create connection_profile" do
    assert_difference('ConnectionProfile.count') do
      post :create, connection_profile: { description: @connection_profile.description, name: @connection_profile.name, type: @connection_profile.type }
    end

    assert_redirected_to connection_profile_path(assigns(:connection_profile))
  end

  test "should show connection_profile" do
    get :show, id: @connection_profile
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @connection_profile
    assert_response :success
  end

  test "should update connection_profile" do
    put :update, id: @connection_profile, connection_profile: { description: @connection_profile.description, name: @connection_profile.name, type: @connection_profile.type }
    assert_redirected_to connection_profile_path(assigns(:connection_profile))
  end

  test "should destroy connection_profile" do
    assert_difference('ConnectionProfile.count', -1) do
      delete :destroy, id: @connection_profile
    end

    assert_redirected_to connection_profiles_path
  end
end
