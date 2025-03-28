module ApplicationHelper
  def navigation_links
    links = []

    # Home is accessible to all authenticated users
    links << { path: root_path, icon: 'bi-house', text: 'Home' }

    # People management - accessible to deans and teachers
    if current_person&.teacher?
      links << { path: people_path, icon: 'bi-people', text: 'People' }
    end

    # School Classes - accessible to all authenticated users
    links << { path: school_classes_path, icon: 'bi-building', text: 'Classes' }

    # Rooms - only accessible to deans and teachers
    if current_person&.teacher?
      links << { path: rooms_path, icon: 'bi-door-open', text: 'Rooms' }
    end

    # Courses - accessible to all authenticated users
    links << { path: courses_path, icon: 'bi-book', text: 'Courses' }

    # Subjects - accessible to deans and teachers
    if current_person&.teacher?
      links << { path: subjects_path, icon: 'bi-journal-text', text: 'Subjects' }
    end

    links
  end

  def can_manage_resource?(resource)
    return false unless current_person

    case resource
    when Grade
      current_person.can_view_grade?(resource)
    else
      current_person.can_manage_resources?
    end
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    direction = (column == params[:sort] && params[:direction] == "asc") ? "desc" : "asc"
    icon = if column == params[:sort]
             direction == "asc" ? "bi-sort-down" : "bi-sort-up"
           else
             "bi-arrow-down-up text-muted"
           end
    link_to request.params.merge(sort: column, direction: direction), class: "text-decoration-none text-dark" do
      raw("#{title} <i class='bi #{icon} ms-1'></i>")
    end
  end

  def sort_indicator(column)
    return "" unless params[:sort] == column
    
    direction = params[:direction] == "asc" ? "asc" : "desc"
    icon_class = direction == "asc" ? "bi-sort-down" : "bi-sort-up"
    
    raw("<i class='bi #{icon_class} ms-1'></i>")
  end
end
