module WeeklyCourseable
  extend ActiveSupport::Concern

  def courses_for_week(date = Date.current)
    # Get the start and end of the week
    week_start = date.beginning_of_week
    week_end = date.end_of_week

    # Filter courses that:
    # 1. Have week_day between Monday (1) and Friday (5)
    # 2. Fall within the specified week's date range
    courses.where(week_day: 1..5)
           .where('DATE(start_at) <= ? AND DATE(end_at) >= ?', week_end, week_start)
           .includes(:subject, :school_class, :teacher)
           .order(:week_day, :start_at)
  end
end
