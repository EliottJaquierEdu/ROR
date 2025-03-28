json.extract! course, :id, :start_at, :end_at, :school_class_id, :created_at, :updated_at
json.term course.term.name
json.url course_url(course, format: :json)
