require 'test_helper'

class StravaControllerTest < ActionController::TestCase
  test "should get download" do
    get :download
    assert_response :success
  end

end
