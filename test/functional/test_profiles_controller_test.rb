require 'test_helper'

class TestProfilesControllerTest < ActionController::TestCase
  setup do
    @test_profile = test_profiles(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:test_profiles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create test_profile" do
    assert_difference('TestProfile.count') do
      post :create, test_profile: { config_method: @test_profile.config_method, config_parameters: @test_profile.config_parameters, name: @test_profile.name }
    end

    assert_redirected_to test_profile_path(assigns(:test_profile))
  end

  test "should show test_profile" do
    get :show, id: @test_profile
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @test_profile
    assert_response :success
  end

  test "should update test_profile" do
    put :update, id: @test_profile, test_profile: { config_method: @test_profile.config_method, config_parameters: @test_profile.config_parameters, name: @test_profile.name }
    assert_redirected_to test_profile_path(assigns(:test_profile))
  end

  test "should destroy test_profile" do
    assert_difference('TestProfile.count', -1) do
      delete :destroy, id: @test_profile
    end

    assert_redirected_to test_profiles_path
  end
end
