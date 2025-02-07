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

## Authentification
https://guides.rubyonrails.org/security.html
Used the default recommanded by Rails : https://rubygems.org/gems/devise
https://github.com/heartcombo/devise

https://www.reddit.com/r/rails/comments/10z34qx/what_is_used_for_authentication_in_rails_nowadays/

http://rawsyntax.com/blog/rails-authentication-plugins/

User will be devise's user (login), and person will be anyone on the website (teacher, student, admin, etc.) and can have an associated user.