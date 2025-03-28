module WeeklyCourseable
  extend ActiveSupport::Concern

  def courses_for_week(date = Date.current)
    # Get the start and end of the week
    week_start = date.beginning_of_week
    week_end = date.end_of_week

    # Filter courses that:
    # 1. Have start_at.wday between Monday (1) and Friday (5)
    # 2. Fall within the specified week's date range
    courses.where(Arel.sql("CAST(strftime('%w', start_at) AS INTEGER) BETWEEN 1 AND 5"))
           .where('DATE(start_at) <= ? AND DATE(end_at) >= ?', week_end, week_start)
           .includes(:subject, :school_class, :teacher)
           .order(Arel.sql("CAST(strftime('%w', start_at) AS INTEGER)"), :start_at)
  end
end
