require "test_helper"

class SchoolClassesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @school_class = school_classes(:one)
  end

  test "should get index" do
    get scool_classes_url
    assert_response :success
  end

  test "should get new" do
    get new_scool_class_url
    assert_response :success
  end

  test "should create school_class" do
    assert_difference("SchoolClass.count") do
      post scool_classes_url, params: { school_class: { master: @school_class.master, name: @school_class.name, room_id: @school_class.room_id, uid: @school_class.uid } }
    end

    assert_redirected_to scool_class_url(SchoolClass.last)
  end

  test "should show school_class" do
    get scool_class_url(@school_class)
    assert_response :success
  end

  test "should get edit" do
    get edit_scool_class_url(@school_class)
    assert_response :success
  end

  test "should update school_class" do
    patch scool_class_url(@school_class), params: { school_class: { master: @school_class.master, name: @school_class.name, room_id: @school_class.room_id, uid: @school_class.uid } }
    assert_redirected_to scool_class_url(@school_class)
  end

  test "should destroy school_class" do
    assert_difference("SchoolClass.count", -1) do
      delete scool_class_url(@school_class)
    end

    assert_redirected_to scool_classes_url
  end
end
