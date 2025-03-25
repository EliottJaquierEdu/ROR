module PeopleHelper
  # Check if the current user can view a specific person
  def can_view_person?(person)
    return false unless person_signed_in?

    # Deans can view all people
    return true if current_person.dean?

    # Teachers can view all people
    return true if current_person.teacher?

    # Students can only view themselves
    if current_person.student?
      return person.id == current_person.id
    end

    false
  end

  # Check if the current user can create people
  def can_create_person?
    return false unless person_signed_in?

    # Only deans can create people
    current_person.dean?
  end

  # Check if the current user can edit a specific person
  def can_edit_person?(person)
    return false unless person_signed_in?

    # Deans can edit all people
    return true if current_person.dean?

    # Teachers can edit their own profile
    if current_person.teacher?
      return person.id == current_person.id
    end

    # Students can edit their own profile
    if current_person.student?
      return person.id == current_person.id
    end

    false
  end

  # Check if the current user can delete a specific person
  def can_delete_person?(person)
    return false unless person_signed_in?

    # Only deans can delete people
    current_person.dean?
  end

  # Get the list of people the current user can see
  def visible_people
    return [] unless person_signed_in?

    # Deans can see all people
    return Person.all if current_person.dean?

    # Teachers can see all people
    return Person.all if current_person.teacher?

    # Students can only see themselves
    if current_person.student?
      return Person.where(id: current_person.id)
    end

    []
  end

  # Get the list of people the current user can see filtered by type
  def visible_people_by_type(type = nil)
    base_scope = if current_person.dean?
                   Person.all
                 else
                   Person.where(id: current_person.id)
                 end

    base_scope = base_scope.where(type: type) if type.present?
    base_scope
  end

  # Check if the current user can view a person's address
  def can_view_address?(person)
    return false unless person_signed_in?

    # Deans can view all addresses
    return true if current_person.dean?

    # Teachers can view addresses of students in their classes
    if current_person.teacher?
      class_ids = SchoolClass.where(master_id: current_person.id).pluck(:id)
      return person.student? && person.school_classes.where(id: class_ids).exists?
    end

    # Students can only view their own address
    if current_person.student?
      return person.id == current_person.id
    end

    false
  end

  # Check if the current user can edit a person's address
  def can_edit_address?(person)
    return false unless person_signed_in?

    # Deans can edit all addresses
    return true if current_person.dean?

    # Teachers can edit addresses of students in their classes
    if current_person.teacher?
      class_ids = SchoolClass.where(master_id: current_person.id).pluck(:id)
      return person.student? && person.school_classes.where(id: class_ids).exists?
    end

    # Students can only edit their own address
    if current_person.student?
      return person.id == current_person.id
    end

    false
  end

  def can_archive_person?(person)
    return false if person == current_person # Can't archive yourself
    current_person.dean?
  end

  def can_unarchive_person?(person)
    current_person.dean?
  end
end
