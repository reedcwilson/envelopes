require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  test "should get the login page" do
    get :new
    assert_response :success
  end
  
  test "correct email and password should successfully log in" do
    user = create :user
    post :create, { email: user.email, password: user.password }
    assert_redirected_to root_url
    assert_not_nil session[:user_id], ":user_id session value was not set"
    assert_equal user.id, session[:user_id]
  end
  
  test "incorrect email/password should not successfully log in" do
    user = create :user
    post :create, { email: user.email, password: 'invalid' }
    assert_response :success
    assert_nil session[:user_id], ":user_id session value was set even though login wasn't successful"
    assert_not_nil flash.alert
  end
  
  test "sessions#destroy should set session[:used_id] to nil" do
    get :destroy
    assert_redirected_to sign_in_url, "didn't get redirected to login page after logging out"
    assert_nil session[:user_id], ":user_id session value was not cleared"
  end
end
