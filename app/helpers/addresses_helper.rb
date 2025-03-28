module AddressesHelper
  # Check if the current user can view addresses
  def can_view_addresses?
    # All authenticated users can view addresses
    person_signed_in?
  end
  
  # Check if the current user can view a specific address
  def can_view_address?(address)
    return false unless person_signed_in?
    
    # Deans can view all addresses
    return true if current_person.dean?
    
    # Teachers can view all addresses
    return true if current_person.teacher?
    
    # Students can only view their own address
    return address.person_id == current_person.id if current_person.student?
    
    false
  end
  
  # Check if the current user can create addresses
  def can_create_address?
    return false unless person_signed_in?
    
    # Only deans can create addresses
    current_person.dean?
  end
  
  # Check if the current user can edit an address
  def can_edit_address?(address)
    return false unless person_signed_in?
    
    # Deans can edit all addresses
    return true if current_person.dean?
    
    # Teachers can't edit addresses
    return false if current_person.teacher?
    
    # Students can't edit addresses
    return false if current_person.student?
    
    false
  end
  
  # Check if the current user can delete an address
  def can_delete_address?(address)
    return false unless person_signed_in?
    
    # Only deans can delete addresses
    current_person.dean?
  end
  
  # Get the list of addresses the current user can see
  def visible_addresses
    return [] unless person_signed_in?
    
    # Deans and teachers can see all addresses
    return Address.all if current_person.dean? || current_person.teacher?
    
    # Students can only see their own address
    return Address.where(person_id: current_person.id) if current_person.student?
    
    []
  end
end
