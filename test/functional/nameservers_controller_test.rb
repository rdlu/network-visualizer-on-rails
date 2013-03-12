require 'test_helper'

class NameserversControllerTest < ActionController::TestCase
  setup do
    @nameserver = nameservers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:nameservers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create nameserver" do
    assert_difference('Nameserver.count') do
      post :create, nameserver: { address: @nameserver.address, internal: @nameserver.internal, name: @nameserver.name, primary: @nameserver.primary, vip: @nameserver.vip }
    end

    assert_redirected_to nameserver_path(assigns(:nameserver))
  end

  test "should show nameserver" do
    get :show, id: @nameserver
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @nameserver
    assert_response :success
  end

  test "should update nameserver" do
    put :update, id: @nameserver, nameserver: { address: @nameserver.address, internal: @nameserver.internal, name: @nameserver.name, primary: @nameserver.primary, vip: @nameserver.vip }
    assert_redirected_to nameserver_path(assigns(:nameserver))
  end

  test "should destroy nameserver" do
    assert_difference('Nameserver.count', -1) do
      delete :destroy, id: @nameserver
    end

    assert_redirected_to nameservers_path
  end
end
