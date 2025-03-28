module RoomsHelper
  # Check if the current user can view a specific room
  def can_view_room?(room)
    return false unless person_signed_in?
    
    # Deans can view all rooms
    return true if current_person.dean?
    
    # Teachers can view all rooms
    return true if current_person.teacher?
    
    # Students can view rooms where their classes are held
    if current_person.student?
      return room.school_classes.where(id: current_person.school_class_ids).exists?
    end
    
    false
  end
  
  # Check if the current user can create rooms
  def can_create_room?
    return false unless person_signed_in?
    
    # Only deans can create rooms
    current_person.dean?
  end
  
  # Check if the current user can edit a specific room
  def can_edit_room?(room)
    return false unless person_signed_in?
    
    # Only deans can edit rooms
    current_person.dean?
  end
  
  # Check if the current user can delete a specific room
  def can_delete_room?(room)
    return false unless person_signed_in?
    
    # Only deans can delete rooms
    current_person.dean?
  end
  
  # Get the list of rooms the current user can see
  def visible_rooms
    return [] unless person_signed_in?
    
    # Deans can see all rooms
    return Room.all if current_person.dean?
    
    # Teachers can see all rooms
    return Room.all if current_person.teacher?
    
    # Students can only see rooms where their classes are held
    if current_person.student?
      return Room.joins(:school_classes)
                 .where(school_classes: { id: current_person.school_class_ids })
                 .distinct
    end
    
    []
  end

  def can_archive_room?(room)
    return false unless person_signed_in?
    return false unless room
    
    # Only deans can archive rooms
    current_person.dean?
  end

  def can_unarchive_room?(room)
    return false unless person_signed_in?
    return false unless room
    
    # Only deans can unarchive rooms
    current_person.dean?
  end
end
