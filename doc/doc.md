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

## Course System and Examinations

### Course Design
Our course system is designed to handle recurring weekly schedules in an academic setting:

1. **Course Structure**
   - Each course has a specific term (e.g., "Autumn Semester 2024")
   - Courses occur on fixed weekdays with set start and end times
   - Each course instance has a specific date, representing when that particular session occurs
   - Courses are linked to a school class and subject (global information about the module, not specific about a particular date)

2. **Weekly Schedule**
   ```ruby
   class Course < ApplicationRecord
     ...
     validates :start_at, presence: true  # DateTime of the specific course instance
     validates :end_at, presence: true    # DateTime of the specific course instance
     validates :week_day, presence: true  # Day of the week (1-7)
   end
   ```

### Examination Date Removal
We initially had a separate `expected_date` field for examinations but removed it for several reasons:

1. **Data Redundancy**
   - Examinations are always linked to a specific course instance
   - The course already contains the date information
   - Having a separate date field was redundant and could lead to inconsistencies

2. **Business Logic**
   - In a school setting, examinations always occur during their respective courses
   - The course date provides the temporal context for the examination
   - Grades and other related data can reference the course date when needed

Doing so simplify examination create process, eliminate the potential date mismatch between courses and examinations.

### Teacher-Course Relationship
We added a direct relationship between teachers and courses to establish clear ownership and responsibility within the academic system:

1. **Course Ownership**
   - Each course must have an assigned teacher
   - This creates clear accountability for course delivery
   - Enables tracking of teacher workload and scheduling

2. **Implementation Benefits**
   ```ruby
   class Course < ApplicationRecord
     belongs_to :teacher, class_name: 'Person'
   end

   class Teacher < Person
     has_many :courses, foreign_key: 'teacher_id'
   end
   ```

3. **Key Advantages**
   - **Schedule Management**: Teachers can easily view their course schedule
   - **Permission Control**: Simplifies access control for course-related operations
   - **Resource Planning**: Helps in managing teacher workload and availability
   - **Reporting**: Enables generation of teacher-specific reports and analytics

4. **System Integration**
   - Teachers can view and manage their assigned courses
   - The relationship supports the examination and grading system
   - Facilitates communication between teachers and students
   - Helps in organizing the school's academic structure

## Concerns and Modules
Our application uses several concerns to encapsulate shared functionality across different models. Here's an overview of each concern:

### WeeklyCourseable
This concern provides functionality for filtering courses based on weekly schedules.

#### Purpose
- Provides a consistent way to filter courses for a specific week
- Ensures courses are properly filtered by both weekday and date range
- Includes necessary associations and ordering

#### Implementation
```ruby
module WeeklyCourseable
  extend ActiveSupport::Concern

  def courses_for_week(date = Date.current)
    week_start = date.beginning_of_week
    week_end = date.end_of_week

    courses.where(week_day: 1..5)
           .where('DATE(start_at) <= ? AND DATE(end_at) >= ?', week_end, week_start)
           .includes(:subject, :school_class)
           .order(:week_day, :start_at)
  end
end
```

#### Usage
Used by:
- `Subject` model - for viewing subject's weekly schedule
- `SchoolClass` model - for class schedule display
- `Teachable` concern - for teacher's schedule management

### Teachable
This concern encapsulates all teacher-related functionality.

#### Purpose
- Manages teacher-specific relationships and methods
- Handles course and class associations
- Provides methods for loading teacher data efficiently

#### Implementation
```ruby
module Teachable
  extend ActiveSupport::Concern
  include WeeklyCourseable

  included do
    has_many :mastered_classes, class_name: 'SchoolClass'
    has_many :courses, foreign_key: 'teacher_id'
    has_many :taught_classes, through: :courses
    has_many :subjects, -> { distinct }, through: :courses
  end

  def school_classes
    # Returns all classes where person is either master or teacher
  end

  def load_show_data(selected_week = nil)
    # Loads teacher data with proper associations
  end
end
```

#### Usage
- Included in the `Teacher` model
- Provides teacher-specific functionality
- Manages relationships between teachers and their classes/courses

### Gradeable
This concern handles grade-related functionality for students.

#### Purpose
- Manages grade calculations and aggregations
- Provides methods for viewing grades by term and subject
- Calculates various types of averages

#### Implementation
```ruby
module Gradeable
  extend ActiveSupport::Concern

  included do
    has_many :grades, foreign_key: "person_id"
  end

  def grades_by_term
    # Organizes grades by term
  end

  def grades_by_term_and_subject
    # Organizes grades by term and subject
  end

  def term_average(term)
    # Calculates average for a specific term
  end

  def overall_average
    # Calculates overall grade average
  end
end
```

#### Usage
- Included in the `Student` model
- Provides comprehensive grade management
- Supports grade reporting and analysis

### WeeklySchedulable
This concern provides helper methods for handling week-based date ranges.

#### Purpose
- Standardizes week range calculations
- Provides consistent week selection logic
- Supports weekly view functionality

#### Implementation
```ruby
module WeeklySchedulable
  extend ActiveSupport::Concern

  def selected_week_range(selected_week = nil)
    week = selected_week ? Date.parse(selected_week.to_s) : Date.current
    {
      start: week.beginning_of_week,
      end: week.end_of_week
    }
  end
end
```

#### Usage
- Used across models that need week-based date handling
- Supports weekly schedule views
- Provides consistent week range calculations

### Benefits of Using Concerns
1. **Code Organization**
   - Separates distinct functionalities into manageable modules
   - Makes the codebase more maintainable
   - Improves code readability

2. **Reusability**
   - Allows sharing of common functionality across models
   - Reduces code duplication
   - Makes it easier to maintain consistent behavior

3. **Modularity**
   - Each concern has a single, well-defined responsibility
   - Makes the code easier to test
   - Facilitates future modifications and extensions

4. **Performance**
   - Includes proper database optimizations
   - Uses eager loading where appropriate
   - Reduces N+1 query problems

## Shared Components and Partials
Our application uses several shared components to maintain consistency and reduce code duplication across views.

### Table Actions Component
The `_table_actions.html.erb` partial provides a standardized way to display action buttons (View, Edit, Delete) in tables across the application.

#### Purpose
- Provides consistent action buttons in tables
- Handles permission checks automatically
- Maintains uniform styling and behavior
- Reduces code duplication

#### Features
- Automatically checks permissions using `can_view_#{resource_name}?`, etc.
- Consistent button styling with Bootstrap classes
- Built-in confirmation dialogs for delete actions

### Show Actions Component
The `_show_actions.html.erb` partial provides a standardized way to display action buttons (Edit, Back, Delete) in show pages.

#### Purpose
- Provides consistent action buttons in show views
- Handles permission checks automatically
- Maintains uniform styling and behavior
- Standardizes delete confirmations

#### Features
- Automatic permission checks
- Consistent button styling
- Bootstrap Icons integration
- Proper routing to index pages

### Edit Actions Component
The `_edit_actions.html.erb` partial provides a standardized way to display action buttons (View, Back) in edit pages.

#### Purpose
- Provides consistent action buttons in edit views
- Handles permission checks automatically
- Maintains uniform styling and behavior
- Reduces code duplication

#### Implementation
```erb
<%# app/views/shared/_edit_actions.html.erb %>
<%= render 'shared/edit_actions',
           resource: @resource,
           resource_name: 'resource',
           index_path: resources_path %>
```

#### Parameters
- `resource`: The resource object to perform actions on
- `resource_name`: The name of the resource (e.g., 'person', 'course')
- `index_path`: The path to return to (e.g., courses_path)

#### Features
- Automatic permission checks for view action
- Consistent button styling
- Bootstrap Icons integration
- Proper routing to index pages

#### Usage Example
```erb
<div class="d-flex justify-content-between align-items-center mb-4">
  <h1>Editing Course</h1>
  <%= render 'shared/edit_actions',
             resource: @course,
             resource_name: 'course',
             index_path: courses_path %>
</div>
```

These components are used throughout the application in:
- Address views
- Course views
- Examination views
- Grade views
- Person views
- Room views
- School Class views
- Subject views

### Benefits of Using These Components
1. **Code Reusability**
2. **Permission Management**
3. **UI Consistency**
4. **Maintainability**