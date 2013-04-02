require 'test_helper'

class ProfilesControllerTest < ActionController::TestCase
  setup do
    @profile = test_profiles(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:profiles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create profile" do
    assert_difference('Profile.count') do
      post :create, profile: { config_method: @profile.config_method, config_parameters: @profile.config_parameters, name: @profile.name }
    end

    assert_redirected_to test_profile_path(assigns(:profile))
  end

  test "should show profile" do
    get :show, id: @profile
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @profile
    assert_response :success
  end

  test "should update profile" do
    put :update, id: @profile, profile: { config_method: @profile.config_method, config_parameters: @profile.config_parameters, name: @profile.name }
    assert_redirected_to test_profile_path(assigns(:profile))
  end

  test "should destroy profile" do
    assert_difference('Profile.count', -1) do
      delete :destroy, id: @profile
    end

    assert_redirected_to test_profiles_path
  end
end
