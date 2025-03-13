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

2. **Permission Methods**
```ruby
# In Person model
def student?
  type == "Student"
end

def teacher?
  type == "Teacher"
end

def can_view_grade?(grade)
  return true if teacher?
  return false unless student?
  grade.person_id == id
end
```

### Controller-Level Authorization
We implement authorization in controllers using before_action filters:

### View-Level Access Control
The views adapt their content based on user type (ex. show only the grades of the current user for students and teachers can see all grades)