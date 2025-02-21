require "application_system_test_case"

class SchoolClassesTest < ApplicationSystemTestCase
  setup do
    @scool_class = scool_classes(:one)
  end

  test "visiting the index" do
    visit scool_classes_url
    assert_selector "h1", text: "SchoolClasses"
  end

  test "should create scool_class" do
    visit scool_classes_url
    click_on "New scool_class"

    fill_in "Master", with: @scool_class.master
    fill_in "Name", with: @scool_class.name
    fill_in "Room", with: @scool_class.room_id
    fill_in "Uid", with: @scool_class.uid
    click_on "Create SchoolClass"

    assert_text "SchoolClass was successfully created"
    click_on "Back"
  end

  test "should update SchoolClass" do
    visit scool_class_url(@scool_class)
    click_on "Edit this scool_class", match: :first

    fill_in "Master", with: @scool_class.master
    fill_in "Name", with: @scool_class.name
    fill_in "Room", with: @scool_class.room_id
    fill_in "Uid", with: @scool_class.uid
    click_on "Update SchoolClass"

    assert_text "SchoolClass was successfully updated"
    click_on "Back"
  end

  test "should destroy SchoolClass" do
    visit scool_class_url(@scool_class)
    click_on "Destroy this scool_class", match: :first

    assert_text "SchoolClass was successfully destroyed"
  end
end
