json.extract! course, :id, :term, :start_at, :end_at, :week_day, :classroom_id, :created_at, :updated_at
json.url course_url(course, format: :json)
