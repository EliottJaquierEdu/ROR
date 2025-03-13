# Doc
## Inheritance :
Use this technique :
https://api.rubyonrails.org/classes/ActiveRecord/Inheritance.html

As suggested by Mr. Ithurbide, we use inheritance to have different types of users instead of composition.

Using this technique, we can have a single table for all the users, and have a type column that will tell you what type of user it is.

If a field is only used by a specific type of user, you can add a condition to the migration to only add the field if the type is correct :
```ruby
add_column :people, :iban, :string, if: "type = 'Teacher'"
```
Teacher inheritance in model :
```ruby
class Teacher < Person
  validates :iban, presence: true
end
```
## Models / schema modifications
### Rename class to school_class
We renamed the class model to school_class to avoid conflicts with the reserved keyword class.
### Remove propotions_asserts
We removed the propotions_asserts table because it was not useful for the project. 
It was used to store which ruby functions to call to know if a student passed but we decided to store this information in the student model (more related to business logic).

## Authentication
References :
- https://guides.rubyonrails.org/security.html
- https://www.reddit.com/r/rails/comments/10z34qx/what_is_used_for_authentication_in_rails_nowadays/
- http://rawsyntax.com/blog/rails-authentication-plugins/

### Devise Implementation
We use the default recommended authentication system ([Devise](https://github.com/heartcombo/devise)) by [Rails](https://rubygems.org/gems/devise).

#### Why Devise?
- Industry standard for Rails authentication
- Provides secure, battle-tested authentication mechanisms
- Handles common security concerns out of the box
- Easy to customize and extend

#### Implementation Choice
We had two options for implementing authentication:
1. Add authentication to the people table
2. Create a separate users table for authentication

We chose to **add authentication to the people table** because:
- Everyone in the application must be able to log in
- People are closely linked to the authentication system
- Simpler architecture with no need for separate user management

#### Devise Configuration
```ruby
# In Person model
devise :database_authenticatable, :registerable,
       :recoverable, :rememberable, :trackable,
       :validatable
```

This configuration provides:
- Database authentication with secure password hashing
- User registration functionality
- Password recovery capabilities
- Remember me functionality
- User activity tracking
- Email validation

## Access Management

### User Types and Permissions
We implement role-based access control (RBAC) using Single Table Inheritance (STI):

1. **User Types**
   - `Student`: Can view their own grades
   - `Teacher`: Can view and manage all grades
   - `Dean`: Can view and manage all resources (administrative role)

2. **Permission Methods**
```ruby
# In Person model
def student?
  type == "Student"
end

def teacher?
  type == "Teacher" || type == "Dean"
end

def dean?
  type == "Dean"
end

def can_view_grade?(grade)
  return true if teacher? || dean?
  return false unless student?
  grade.person_id == id
end

def can_manage_resources?
  dean?
end
```

### Dean Role Implementation
We added a Dean role to provide administrative capabilities within the school management system.

#### Why a Dean Role?
- Need for a dedicated administrative role with higher permissions
- Clear separation between teaching and administrative responsibilities
- Centralized management of school resources (people, classes, rooms, etc.)

#### Implementation Approach
We implemented the Dean role using inheritance, making Dean inherit from Teacher:

```ruby
class Dean < Teacher
  # Dean inherits all Teacher attributes and validations
end
```

This approach offers several advantages:
1. **Reuse of Teacher attributes**: Deans inherit all Teacher attributes and validations (including IBAN and teacher_status)
2. **Simplified model structure**: No need for additional tables or complex relationships
3. **Clear permission hierarchy**: Deans can do everything Teachers can do, plus administrative tasks

#### Authorization Implementation
We implemented resource management authorization using a before_action filter in controllers:

```ruby
# In ApplicationController
def authorize_resource_management
  unless current_person.can_manage_resources?
    flash[:alert] = "You are not authorized to manage this resource."
    redirect_back(fallback_location: root_path)
  end
end

# In resource controllers
before_action :authorize_resource_management, only: %i[ new create edit update destroy ]
```

This ensures that only Deans can create, edit, and delete resources, while Teachers can only view them.

### Controller-Level Authorization
We implement authorization in controllers using before_action filters:

### View-Level Access Control
The views adapt their content based on user type (ex. show only the grades of the current user for students and teachers can see all grades)