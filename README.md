Voici la documentation mise à jour en incluant `uru` comme alternative à `rbenv` :

---

# **School Data Manager**

A Ruby on Rails application to manage school-related data, including addresses, people, teachers, students, school classes, courses, subjects, grades, and more.

## **Installation**

### 1. **Ensure Ruby Version Compatibility**
This project uses Ruby `3.4.1`. You can use `rbenv` (Linux/macOS) or `uru` (Windows) to set up the correct Ruby version.

### 2. **Install Bundler**
Ensure that Bundler is installed:
```shell
gem install bundler
```

### 3. **Install Dependencies**
Install all dependencies defined in the `Gemfile`:
```shell script
bundle install
```

---

## **Dependencies**

Here are the key dependencies used in this project:

- **Rails:** `8.0.1`
- **Ruby:** `3.4.1`
- **SQLite:** `>= 2.1`
- **Selenium WebDriver (for tests):** `4.28.0`
- **Puma (Server):** `6.6.0`
- **Devise:** Used for user authentication
- **Propshaft:** Modern asset pipeline for Rails
- **Turbo-Rails & Stimulus-Rails:** SPA-like page acceleration and JS framework
- **Kamal:** Deployment tool for Rails applications via Docker
- For detailed gem versions, refer to the `Gemfile` or `Gemfile.lock`.

---

## **Setup the Database**

1. **Create and Migrate the Database**
   Run the following to create and migrate your database:
```shell script
rails db:create
rails db:migrate
```

2. **Seed the Development Database (Optional)**
   Populates the database with example data:
```shell script
rails db:seed
```

3. **Prepare Test Database**
Precompile assets before production to optimize performance:
```shell script
rails assets:precompile
```
---

## **Running the Application**

1. **Start the Rails Server**
   Run the Rails server locally:
```shell script
rails server
```

2. **Access the Application**
   The application will run on [http://localhost:3000](http://localhost:3000).

3. **Example Accounts**
   After running `rails db:seed`, you can connect with the following accounts:

   **Dean Account:**
   - Email: `pierre.dubois@example.com`
   - Password: `password`

   **Teacher Account:**
   - Email: `sophie.blanc@example.com`
   - Password: `password`

   **Student Account:**
   - Email: `marie.favre@example.com`
   - Password: `password`

4. **Environment Variables**
    - Use `config/master.key` for Rails credentials.
    - For production deployments, pass `RAILS_MASTER_KEY` to the Docker container.