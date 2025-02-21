# **School Data Manager**

A Ruby on Rails application to manage school-related data, including addresses, people, teachers, students, school classes, courses, subjects, grades, and more.

## **Installation**

1. **Clone the Repository**
2. **Ensure Ruby Version Compatibility**  
   This project uses Ruby `3.4.1`. Use a Ruby version manager (e.g., `rbenv` or `RVM`) to set the proper version:
```shell script
rbenv install 3.4.1
rbenv local 3.4.1
```

3. **Install Bundler**  
   Make sure you have Bundler installed:
```shell script
gem install bundler
```

4. **Install Dependencies**  
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
   Ensure the `test` database is correctly set up:
```shell script
rails db:test:prepare
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

3. **Environment Variables**
    - Use `config/master.key` for Rails credentials.
    - For production deployments, pass `RAILS_MASTER_KEY` to the Docker container.

Optional: Precompile assets before production to optimize performance:
```shell script
rails assets:precompile
```

---

## **Test the Application**

This project includes a rich suite of tests, including system tests. Here's how to run them:

1. **Run All Tests**  
   Run all available test suites:
```shell script
rails test
```

2. **System Tests**  
   To test the application’s end-to-end workflows, run system tests:
```shell script
rails test:system
```

Ensure you have the WebDriver installed (e.g., `chromedriver` for Chrome).

3. **Debugging Tests**  
   Run specific tests if required:
```shell script
rails test test/system/<specific_test>.rb
```

---

## **Run in Docker**

This application has support for Docker-based deployment. Use the provided `Dockerfile`:

1. **Build the Image**
```shell script
docker build -t school_data_manager .
```

2. **Run the Container**  
   Ensure the Rails master key is passed if required:
```shell script
docker run -d -p 80:80 -e RAILS_MASTER_KEY=<your-master-key> --name school_data_manager school_data_manager
```

---

## **Deployment Notes**

- **Production Assets:** Precompile assets with:
```shell script
rails assets:precompile
```
- **Environment-Specific Commands:** Run commands in the appropriate Rails environment by specifying `RAILS_ENV`:
```shell script
RAILS_ENV=production rails db:migrate
```

- **Ensure Secure Deployment:**
  Refer to the [Rails Security Guide](https://guides.rubyonrails.org/security.html) to secure sensitive credentials. s! 🚀