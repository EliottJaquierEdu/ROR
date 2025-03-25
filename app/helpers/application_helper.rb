module ApplicationHelper
  def navigation_links
    links = []

    # Home is accessible to all authenticated users
    links << { path: root_path, icon: 'bi-house', text: 'Home' }

    # People management - accessible to deans and teachers
    if current_person&.teacher?
      links << { path: people_path, icon: 'bi-people', text: 'People' }
    end

    # Addresses - only accessible to deans
    if current_person&.dean?
      links << { path: addresses_path, icon: 'bi-geo-alt', text: 'Addresses' }
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
end
