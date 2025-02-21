require "test_helper"

class SchoolClassesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @scool_class = scool_classes(:one)
  end

  test "should get index" do
    get scool_classes_url
    assert_response :success
  end

  test "should get new" do
    get new_scool_class_url
    assert_response :success
  end

  test "should create scool_class" do
    assert_difference("SchoolClass.count") do
      post scool_classes_url, params: { scool_class: { master: @scool_class.master, name: @scool_class.name, room_id: @scool_class.room_id, uid: @scool_class.uid } }
    end

    assert_redirected_to scool_class_url(SchoolClass.last)
  end

  test "should show scool_class" do
    get scool_class_url(@scool_class)
    assert_response :success
  end

  test "should get edit" do
    get edit_scool_class_url(@scool_class)
    assert_response :success
  end

  test "should update scool_class" do
    patch scool_class_url(@scool_class), params: { scool_class: { master: @scool_class.master, name: @scool_class.name, room_id: @scool_class.room_id, uid: @scool_class.uid } }
    assert_redirected_to scool_class_url(@scool_class)
  end

  test "should destroy scool_class" do
    assert_difference("SchoolClass.count", -1) do
      delete scool_class_url(@scool_class)
    end

    assert_redirected_to scool_classes_url
  end
end
