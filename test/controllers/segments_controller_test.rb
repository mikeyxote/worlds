require 'test_helper'

class SegmentsControllerTest < ActionController::TestCase
  setup do
    @segment = segments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:segments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create segment" do
    assert_difference('Segment.count') do
      post :create, segment: { points: @segment.points }
    end

    assert_redirected_to segment_path(assigns(:segment))
  end

  test "should show segment" do
    get :show, id: @segment
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @segment
    assert_response :success
  end

  test "should update segment" do
    patch :update, id: @segment, segment: { points: @segment.points }
    assert_redirected_to segment_path(assigns(:segment))
  end

  test "should destroy segment" do
    assert_difference('Segment.count', -1) do
      delete :destroy, id: @segment
    end

    assert_redirected_to segments_path
  end
end
