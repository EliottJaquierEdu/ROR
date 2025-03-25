module WeeklySchedulable
  extend ActiveSupport::Concern

  def selected_week_range(selected_week = nil)
    week = selected_week ? Date.parse(selected_week.to_s) : Date.current.beginning_of_week
    {
      start: week.beginning_of_week,
      end: week.end_of_week
    }
  end
end
