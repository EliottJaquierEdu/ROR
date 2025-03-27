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

### Examination Date Removal
We initially had a separate `expected_date` field for examinations but removed it for several reasons:
Examinations are always linked to a specific course instance (see course design chapter for more info) and the course already contains the date information
- In a school setting, examinations always occur during their respective courses
- The course date provides the temporal context for the examination
- Grades and other related data can reference the course date when needed
This eliminate the potential date mismatch between courses and examinations (making it compliant with SQL normal forms)

### Term Externalization
We externalized the term from courses into its own table to improve data consistency and management:
- Terms are now first-class entities with their own attributes (name, start_at, end_at)
- Prevents duplicate term names through database constraints
- Centralizes term date validation and management
- Makes it easier to query and manage courses by term
- Reduces data redundancy by storing term information once
- Maintains referential integrity through foreign key constraints
This change follows database normalization principles and makes the system more maintainable.

### Teacher-Course Relationship
We added a direct relationship between teachers and courses to establish clear ownership and responsibility within the academic system:
   - Each course must have an assigned teacher. This creates clear accountability for course delivery and enables tracking of teacher workload and scheduling

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
We implemented the Dean role using inheritance, making Dean inherit from Teacher (so Deans inherit all Teacher attributes and validations (including IBAN and teacher_status), No need for additional tables or complex relationships, Deans can do everything Teachers can do, plus administrative tasks):

```ruby
class Dean < Teacher
  # Dean inherits all Teacher attributes and validations
end
```

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
   - Each course belongs to a specific term (e.g., "Autumn Semester 2024")
   - Terms have their own start and end dates, ensuring data consistency
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

## Concerns and Modules
Our application uses several concerns to encapsulate shared functionality across different models. Here's an overview of each concern:

### WeeklyCourseable
This concern provides functionality for filtering courses based on weekly schedules.

#### Purpose
- Provides a consistent way to filter courses for a specific week
- Ensures courses are properly filtered by both weekday and date range
- Includes necessary associations and ordering

#### Usage
Used by:
- `Subject` model - for viewing subject's weekly schedule
- `SchoolClass` model - for class schedule display
- `Teachable` concern - for teacher's schedule management

### Gradeable
This concern handles grade-related functionality for students.

#### Purpose
- Manages grade calculations and aggregations
- Provides methods for viewing grades by term and subject
- Calculates various types of averages
- Handles grade filtering for failed school years

#### Grade Filtering System
The system implements a sophisticated filtering mechanism to handle grades from failed school years:

1. **Time-Based Filtering**
   - Grades are filtered based on their `effective_date`
   - School year dates are defined by constants:
     ```ruby
     SCHOOL_YEAR_START_MONTH = 9  # September
     SCHOOL_YEAR_END_MONTH = 8    # August
     ```

2. **Grade Categories**
   - `applicable_grades`: Grades outside the failed school year period
   - `failed_period_grades`: Grades from the failed school year period
   - All calculations (averages, etc.) use only applicable grades

3. **Failed Year Detection**
   - Uses the new vs old school class year to determine the date range
   - Only considers the most recent failed year (if a student fail in it's second year, his first year grade needs to remain)

4. **Visual Representation**
   - Applicable grades are displayed normally
   - Failed period grades are shown with reduced opacity (to show visually that they are no longer applicable, but remains for a full historical purpose)
   - All averages exclude grades from the failed period

This system ensures that:
- Grades from failed years don't affect current performance metrics
- Historical data is preserved but visually distinguished
- Calculations accurately reflect current academic standing
- The system maintains data integrity while providing clear visual feedback

### WeeklySchedulable
This concern provides helper methods for handling week-based date ranges.

#### Purpose
- Standardizes week range calculations
- Provides consistent week selection logic
- Supports weekly view functionality

#### Usage
- Used across models that need week-based date handling
- Supports weekly schedule views
- Provides consistent week range calculations

### Benefits of Using Concerns
Benefits of Using Concerns: Enhances code organization, readability, and modularity by separating functionalities into reusable modules. 
Improves performance through database optimizations and reduced code duplication.

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

These components are used throughout the application in:
- Address views
- Course views
- Examination views
- Grade views
- Person views
- Room views
- School Class views
- Subject views

## Pagination Implementation

### Kaminari Integration
Kaminari was chosen for its seamless Rails and ActiveRecord integration, built-in view helpers, and asset pipeline support. 
It offers configurable pagination, customizable templates, and maintains scopes. 
Additionally, it integrates well with Bootstrap for a responsive and consistent UI.

### Implementation Approach
**Controller Integration**
```ruby
def index
  @courses = @courses.page(params[:page]).per(10)
end
```
**View Templates**

We created custom Bootstrap-styled templates for Kaminari in `app/views/kaminari/`

### Integration with Existing Features

1. **Filter Compatibility**
The pagination system maintains all active filters when navigating between pages:
- Term filters
- Day filters
- Year filters
- Subject filters

2. **Sort Compatibility**
Sorting is preserved across pagination:
```ruby
@courses = @courses.order("#{sort_column} #{sort_direction}")
                  .page(params[:page])
```

3. **Performance Optimization**
- Eager loading of associations
- Proper join handling
- Efficient query generation

### Benefits
1. **User Experience**
   - Reduced page load times
   - Easier navigation of large datasets
   - Clear visual feedback
   - Consistent styling

2. **Developer Experience**
   - Clean, maintainable code
   - Easy to customize
   - Well-documented
   - Strong community support

3. **System Performance**
   - Reduced memory usage
   - Optimized database queries
   - Efficient resource utilization

### Usage Example
```erb
<div class="d-flex justify-content-center mt-4">
  <%= paginate @courses, theme: 'bootstrap5' %>
</div>
```

## Student Promotion System

### Overview
The student promotion system handles the end-of-year process where students are either promoted to the next year or required to repeat their current year based on their academic performance.

### Grade Requirements
- Students with sufficient grades (average >= 4.0) are eligible for promotion to the next year
- Students with insufficient grades remain in their current year and are moved to a repeat class
- The system maintains historical grade data while ensuring only applicable grades affect current academic standing

### Promotion Process
1. **Initial Assessment**
   - System identifies students eligible for promotion based on their grades
   - Students are split into two groups:
     - `@students_to_promote`: Students with sufficient grades
     - `@students_to_repeat`: Students with insufficient grades

2. **Class Selection**
   - For promotion: Select a target (more advanced one, in level / difficulty) class in the next year (year + 1)
   - For repeating: Select a repeat class in the next year (but with the same level)
   - Both selections can be made independently

3. **Processing**
   - Students with sufficient grades are moved to the selected promotion class
   - Students with insufficient grades are moved to the selected repeat class
   - The system maintains all historical grade data while ensuring only applicable grades affect current academic standing

4. **Grade Handling**
   - Grades from failed years are preserved but marked as non-applicable
   - Only grades from the current academic year affect promotion decisions
   - Historical grades remain visible for reference but don't impact current standing

NOTE: For now, we only know if a student repeat class by the master_id of the two class being different. If the master_id is not guarenteed to be the same accroos all year of one class, we will need to add a level/difficulty field to identify repeated classes.