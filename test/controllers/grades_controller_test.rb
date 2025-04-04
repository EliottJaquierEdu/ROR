require "test_helper"

class GradesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @grade = grades(:one)
  end

  test "should get index" do
    get grades_url
    assert_response :success
  end

  test "should get new" do
    get new_grade_url
    assert_response :success
  end

  test "should create grade" do
    assert_difference("Grade.count") do
      post grades_url, params: { grade: { effective_date: @grade.effective_date, examination_id: @grade.examination_id, student_id: @grade.student_id, value: @grade.value } }
    end

    assert_redirected_to grade_url(Grade.last)
  end

  test "should show grade" do
    get grade_url(@grade)
    assert_response :success
  end

  test "should get edit" do
    get edit_grade_url(@grade)
    assert_response :success
  end

  test "should update grade" do
    patch grade_url(@grade), params: { grade: { effective_date: @grade.effective_date, examination_id: @grade.examination_id, student_id: @grade.student_id, value: @grade.value } }
    assert_redirected_to grade_url(@grade)
  end

  test "should destroy grade" do
    assert_difference("Grade.count", -1) do
      delete grade_url(@grade)
    end

    assert_redirected_to grades_url
  end
end
