module SchoolClassesHelper
  # Check if the current user can view a specific school class
  def can_view_school_class?(school_class)
    return false unless person_signed_in?
    
    # Deans can view all classes
    return true if current_person.dean?
    
    # Teachers can view classes they teach
    if current_person.teacher?
      return school_class.master_id == current_person.id
    end
    
    # Students can view their own classes
    if current_person.student?
      return school_class.students.include?(current_person)
    end
    
    false
  end
  
  # Check if the current user can create school classes
  def can_create_school_class?
    return false unless person_signed_in?
    
    # Only deans can create classes
    current_person.dean?
  end
  
  # Check if the current user can edit a specific school class
  def can_edit_school_class?(school_class)
    return false unless person_signed_in?
    
    # Deans can edit all classes
    return true if current_person.dean?
    
    # Teachers can edit classes they teach
    if current_person.teacher?
      return school_class.master_id == current_person.id
    end
    
    false
  end
  
  # Check if the current user can delete a specific school class
  def can_delete_school_class?(school_class)
    return false unless person_signed_in?
    
    # Only deans can delete classes
    current_person.dean?
  end
  
  # Get the list of school classes the current user can see
  def visible_school_classes
    return [] unless person_signed_in?
    
    # Deans can see all classes
    return SchoolClass.all if current_person.dean?
    
    # Teachers can see classes they teach
    if current_person.teacher?
      return SchoolClass.where(master_id: current_person.id)
    end
    
    # Students can see their own classes
    if current_person.student?
      return current_person.school_classes
    end
    
    []
  end
  
  # Check if the current user can manage students in a class
  def can_manage_students?(school_class)
    return false unless person_signed_in?
    
    # Deans can manage students in all classes
    return true if current_person.dean?
    
    # Teachers can manage students in classes they teach
    if current_person.teacher?
      return school_class.master_id == current_person.id
    end
    
    false
  end
  
  # Check if the current user can manage examinations in a class
  def can_manage_examinations?(school_class)
    return false unless person_signed_in?
    
    # Deans can manage examinations in all classes
    return true if current_person.dean?
    
    # Teachers can manage examinations in classes they teach
    if current_person.teacher?
      return school_class.master_id == current_person.id
    end
    
    false
  end
end 